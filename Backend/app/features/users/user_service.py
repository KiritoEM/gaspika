from fastapi import HTTPException
from app.core.storages.interfaces import StorageProvider
from app.core.utils.hashing import verify_hash
from app.features.devices.device_repository import DeviceRepository
from app.features.users.user_preference_repository import UserPreferenceRepository
from app.features.users.user_repository import UserRepository
from app.features.users.user_schemas import ChangePasswordDTO, DeleteAccountDTO, UpdateNotificationPreferenceDTO, UpdateUserDTO, UserCreateDTO

class UserServices:
    def __init__(
        self,
        user_repo: UserRepository,
        device_repo: DeviceRepository,
        preference_repo: UserPreferenceRepository = None,
        storage_provider: StorageProvider = None,
        redis_client = None
    ):
        self.user_repo = user_repo
        self.device_repo = device_repo
        self.preference_repo = preference_repo
        self.storage_provider = storage_provider
        self.redis_client = redis_client

    async def create_user(self, data: UserCreateDTO):
        if (await self.user_repo.get_user_by_email(data.email)):
            raise HTTPException(status_code=409, detail="Un compte avec cet email existe déja.")

        created_user = await self.user_repo.create(**data.model_dump())

        # create device with FCM token
        # try:
        #     await self.device_repo.create(data.fcm_token, str(created_user.id))
        # except Exception as e:
        #     print(f"Impossible de créer le device: {str(e)}")
        #     raise HTTPException(status_code=500, detail="Impossible de créer le device")


        return created_user

    async def get_user_by_id(self, user_id: str):
        return await self.user_repo.get_user_by_id(user_id)

    async def logout(self, fcm_token: str):
        deleted = await self.device_repo.delete_by_fcm_token(fcm_token)

        if not deleted:
            raise HTTPException(status_code=500, detail=f"Impossible de supprimer le Device avec le fcm_token: {fcm_token}")

    async def update_user(self, user_id: str, data: UpdateUserDTO):
        if data.email:
            existing_user = await self.user_repo.get_user_by_email(data.email)

            if existing_user and str(existing_user.id) != str(user_id):
                raise HTTPException(status_code=409, detail="Un compte avec cet email existe déja.")

        updated_user = await self.user_repo.update_user(user_id, data)

        if not updated_user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")

        return updated_user

    async def change_password(self, user_id: str, data: ChangePasswordDTO):
        user = await self.user_repo.get_user_by_id(user_id)

        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")

        if not verify_hash(data.current_password, user.password):
            raise HTTPException(status_code=401, detail="Mot de passe incorrect.")

        if verify_hash(data.new_password, user.password):
            raise HTTPException(status_code=400, detail="Le nouveau mot de passe doit être différent de l'ancien.")

        return await self.user_repo.update_password(user_id, data.new_password)

    async def get_notification_preferences(self, user_id: str):
        return await self.preference_repo.get_or_create(user_id)

    async def update_notification_preferences(self, user_id: str, data: UpdateNotificationPreferenceDTO):
        updated_preference = await self.preference_repo.update(user_id, data)

        if not updated_preference:
            raise HTTPException(status_code=404, detail="Préférences de notification introuvables.")

        return updated_preference

    async def delete_account(self, user_id: str, data: DeleteAccountDTO):
        user = await self.user_repo.get_user_by_id(user_id)

        if not user:
            raise HTTPException(status_code=404, detail="Utilisateur introuvable.")

        if not verify_hash(data.password, user.password):
            raise HTTPException(status_code=401, detail="Mot de passe incorrect.")

        # delete images from the cloud
        delete_urls = await self.user_repo.get_image_delete_urls(user_id)

        for delete_url in delete_urls:
            try:
                await self.storage_provider.delete({"delete_url": delete_url})
            except Exception as e:
                print(f"Impossible de supprimer l'image {delete_url} depuis le cloud: {str(e)}")

        await self.user_repo.purge_user_data(user_id)
        await self.user_repo.soft_delete(user_id)

        # clean user cache
        try:
            await self.redis_client.delete(f"notification_counter:{user_id}")
            await self.redis_client.delete(f"shopping-items:{user_id}")
        except Exception as e:
            print(f"Impossible de nettoyer le cache de l'utilisateur {user_id}: {str(e)}")
