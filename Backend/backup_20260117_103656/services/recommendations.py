def compute_optimal_quantity(base_per_person: int | None, household_size: int) -> int:
    if not base_per_person or base_per_person <= 0:
        base_per_person = 1
    extra_factor = 1.0
    if household_size > 4:
        extra_factor = 1.1
    return int(round(base_per_person * household_size * extra_factor))