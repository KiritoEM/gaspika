# setup_structure.ps1
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SCRIPT DE RESTRUCTURATION DU PROJET" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. BACKUP AUTOMATIQUE
Write-Host "1. CREATION DU BACKUP..." -ForegroundColor Yellow
$backupName = "backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
if (Test-Path "app") {
    Copy-Item -Path "app" -Destination $backupName -Recurse -Force
    Write-Host "   ✓ Backup créé: $backupName" -ForegroundColor Green
} else {
    Write-Host "   ! Dossier 'app' non trouvé" -ForegroundColor Red
}

Write-Host ""

# 2. CREATION DE LA NOUVELLE STRUCTURE
Write-Host "2. CREATION DE LA STRUCTURE..." -ForegroundColor Yellow

# Dossiers principaux
$folders = @(
    # Core
    "app",
    "app/core",
    "app/core/middlewares", 
    "app/core/utils",
    
    # Features
    "app/features",
    "app/features/auth",
    "app/features/auth/tests",
    "app/features/users",
    "app/features/users/tests",
    "app/features/products",
    "app/features/products/tests",
    "app/features/categories",
    "app/features/categories/tests",
    "app/features/shopping_lists",
    "app/features/shopping_lists/tests",
    "app/features/shopping_items",
    "app/features/shopping_items/tests",
    "app/features/predictions",
    "app/features/predictions/tests",
    "app/features/recommendations",
    "app/features/recommendations/tests",
    
    # Tests globaux
    "app/tests",
    "app/tests/integration",
    "app/tests/unit"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        Write-Host "   ✓ Créé: $folder" -ForegroundColor Green
    } else {
        Write-Host "   • Existe déjà: $folder" -ForegroundColor Gray
    }
}

Write-Host ""

# 3. CREATION DES FICHIERS __init__.py
Write-Host "3. CREATION DES FICHIERS __init__.py..." -ForegroundColor Yellow

$initFiles = @(
    # Core
    "app/__init__.py",
    "app/core/__init__.py",
    "app/core/middlewares/__init__.py",
    "app/core/utils/__init__.py",
    
    # Features
    "app/features/__init__.py",
    "app/features/auth/__init__.py",
    "app/features/auth/tests/__init__.py",
    "app/features/users/__init__.py",
    "app/features/users/tests/__init__.py",
    "app/features/products/__init__.py",
    "app/features/products/tests/__init__.py",
    "app/features/categories/__init__.py",
    "app/features/categories/tests/__init__.py",
    "app/features/shopping_lists/__init__.py",
    "app/features/shopping_lists/tests/__init__.py",
    "app/features/shopping_items/__init__.py",
    "app/features/shopping_items/tests/__init__.py",
    "app/features/predictions/__init__.py",
    "app/features/predictions/tests/__init__.py",
    "app/features/recommendations/__init__.py",
    "app/features/recommendations/tests/__init__.py",
    
    # Tests globaux
    "app/tests/__init__.py",
    "app/tests/integration/__init__.py",
    "app/tests/unit/__init__.py"
)

foreach ($file in $initFiles) {
    if (-not (Test-Path $file)) {
        New-Item -ItemType File -Force -Path $file | Out-Null
        Write-Host "   ✓ Créé: $file" -ForegroundColor Green
    } else {
        Write-Host "   • Existe déjà: $file" -ForegroundColor Gray
    }
}

Write-Host ""

# 4. CREATION DES FICHIERS VIDE POUR CHAQUE FEATURE
Write-Host "4. CREATION DES FICHIERS DE STRUCTURE..." -ForegroundColor Yellow

$featureFiles = @(
    # Pour chaque feature
    @{Path="app/features/auth/api.py"; Description="Routes auth"},
    @{Path="app/features/auth/schemas.py"; Description="Schémas auth"},
    @{Path="app/features/auth/models.py"; Description="Modèles auth"},
    @{Path="app/features/auth/repository.py"; Description="Repository auth"},
    @{Path="app/features/auth/service.py"; Description="Service auth"},
    @{Path="app/features/auth/tests/test_auth.py"; Description="Tests auth"},
    
    @{Path="app/features/users/api.py"; Description="Routes users"},
    @{Path="app/features/users/schemas.py"; Description="Schémas users"},
    @{Path="app/features/users/models.py"; Description="Modèles users"},
    @{Path="app/features/users/repository.py"; Description="Repository users"},
    @{Path="app/features/users/service.py"; Description="Service users"},
    @{Path="app/features/users/tests/test_users.py"; Description="Tests users"},
    
    @{Path="app/features/products/api.py"; Description="Routes products"},
    @{Path="app/features/products/schemas.py"; Description="Schémas products"},
    @{Path="app/features/products/models.py"; Description="Modèles products"},
    @{Path="app/features/products/repository.py"; Description="Repository products"},
    @{Path="app/features/products/service.py"; Description="Service products"},
    @{Path="app/features/products/tests/test_products.py"; Description="Tests products"},
    
    @{Path="app/features/categories/api.py"; Description="Routes categories"},
    @{Path="app/features/categories/schemas.py"; Description="Schémas categories"},
    @{Path="app/features/categories/models.py"; Description="Modèles categories"},
    @{Path="app/features/categories/repository.py"; Description="Repository categories"},
    @{Path="app/features/categories/service.py"; Description="Service categories"},
    @{Path="app/features/categories/tests/test_categories.py"; Description="Tests categories"},
    
    @{Path="app/features/shopping_lists/api.py"; Description="Routes shopping_lists"},
    @{Path="app/features/shopping_lists/schemas.py"; Description="Schémas shopping_lists"},
    @{Path="app/features/shopping_lists/models.py"; Description="Modèles shopping_lists"},
    @{Path="app/features/shopping_lists/repository.py"; Description="Repository shopping_lists"},
    @{Path="app/features/shopping_lists/service.py"; Description="Service shopping_lists"},
    @{Path="app/features/shopping_lists/tests/test_shopping_lists.py"; Description="Tests shopping_lists"},
    
    @{Path="app/features/shopping_items/api.py"; Description="Routes shopping_items"},
    @{Path="app/features/shopping_items/schemas.py"; Description="Schémas shopping_items"},
    @{Path="app/features/shopping_items/models.py"; Description="Modèles shopping_items"},
    @{Path="app/features/shopping_items/repository.py"; Description="Repository shopping_items"},
    @{Path="app/features/shopping_items/service.py"; Description="Service shopping_items"},
    @{Path="app/features/shopping_items/tests/test_shopping_items.py"; Description="Tests shopping_items"},
    
    @{Path="app/features/predictions/api.py"; Description="Routes predictions"},
    @{Path="app/features/predictions/schemas.py"; Description="Schémas predictions"},
    @{Path="app/features/predictions/models.py"; Description="Modèles predictions"},
    @{Path="app/features/predictions/repository.py"; Description="Repository predictions"},
    @{Path="app/features/predictions/service.py"; Description="Service predictions"},
    @{Path="app/features/predictions/tests/test_predictions.py"; Description="Tests predictions"},
    
    @{Path="app/features/recommendations/api.py"; Description="Routes recommendations"},
    @{Path="app/features/recommendations/schemas.py"; Description="Schémas recommendations"},
    @{Path="app/features/recommendations/models.py"; Description="Modèles recommendations"},
    @{Path="app/features/recommendations/repository.py"; Description="Repository recommendations"},
    @{Path="app/features/recommendations/service.py"; Description="Service recommendations"},
    @{Path="app/features/recommendations/tests/test_recommendations.py"; Description="Tests recommendations"},
    
    # Core files
    @{Path="app/main.py"; Description="Main FastAPI"},
    @{Path="app/core/config.py"; Description="Configuration"},
    @{Path="app/core/database.py"; Description="Base de données"},
    @{Path="app/core/dependencies.py"; Description="Dépendances"},
    @{Path="app/core/security.py"; Description="Sécurité"},
    @{Path="app/core/exceptions.py"; Description="Exceptions"},
    @{Path="app/core/logging.py"; Description="Logging"},
    @{Path="app/core/redis_client.py"; Description="Redis"},
    @{Path="app/core/enums.py"; Description="Enums"},
    @{Path="app/core/middlewares/auth.py"; Description="Middleware auth"},
    @{Path="app/core/middlewares/logging_middleware.py"; Description="Middleware logging"},
    @{Path="app/core/middlewares/cors_middleware.py"; Description="Middleware CORS"},
    @{Path="app/core/utils/hashing.py"; Description="Utils hashing"},
    @{Path="app/core/utils/pagination.py"; Description="Utils pagination"},
    
    # Tests globaux
    @{Path="app/tests/conftest.py"; Description="Configuration tests"}
)

foreach ($fileInfo in $featureFiles) {
    $filePath = $fileInfo.Path
    $description = $fileInfo.Description
    
    if (-not (Test-Path $filePath)) {
        # Créer le fichier avec un commentaire
        $content = "# $description`n# Fichier créé automatiquement par le script de restructuration`n"
        Set-Content -Path $filePath -Value $content
        Write-Host "   ✓ Créé: $filePath" -ForegroundColor Green
    } else {
        Write-Host "   • Existe déjà: $filePath" -ForegroundColor Gray
    }
}

Write-Host ""

# 5. CREATION DU FICHIER MAIN.PY AVEC CONTENU DE BASE
Write-Host "5. CONFIGURATION DU FICHIER MAIN.PY..." -ForegroundColor Yellow

$mainPyContent = @"
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "API Restructurée", "version": settings.VERSION}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Les imports des routeurs seront ajoutés ici progressivement
# from app.features.auth.api import router as auth_router
# app.include_router(auth_router, prefix="/auth", tags=["auth"])
"@

Set-Content -Path "app/main.py" -Value $mainPyContent
Write-Host "   ✓ Fichier main.py configuré" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STRUCTURE TERMINEE AVEC SUCCES!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prochaines étapes:" -ForegroundColor Yellow
Write-Host "1. Déplacer vos fichiers existants dans la nouvelle structure" -ForegroundColor White
Write-Host "2. Adapter les imports dans chaque fichier" -ForegroundColor White
Write-Host "3. Tester module par module" -ForegroundColor White
Write-Host ""
Write-Host "Backup disponible dans: $backupName" -ForegroundColor Magenta