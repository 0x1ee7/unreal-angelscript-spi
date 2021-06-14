import Space.SpaceProjectile;

class AEnemyMovement: UActorComponent{
    float Direction = 1.f;
    float Speed = 1.f;

    UFUNCTION()
    void SwitchDirection()
    {
        Direction *= -1.f;
    }

    void Pause()
    {
        if(Speed != 0.f)
        {
            Speed = 0.f;
        }
        else
        {
           Speed = 1.f;
        }
    }

    float Velocity()
    {
        return Direction * Speed;
    }

};

class ASpaceActorBase: APawn
{

    AEnemyMovement Movement;
    float HorizontalSpeed = 0.f;

    UPROPERTY()
    float Health = 100.f;

    UPROPERTY()
    EProjectileType RespondsToDamageBy;

    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent ActorMesh;
    default ActorMesh.EnableGravity = false;
    default ActorMesh.CollisionProfileName = n"OverlapAllDynamic";

    UPROPERTY(DefaultComponent,Attach = ActorMesh)
    USceneComponent ProjectileSpawn;
    default ProjectileSpawn.WorldLocation = FVector(0.f, 0.f, 30.f);

    UPROPERTY(Category="Projectile Settings")
    TSubclassOf<ASpaceProjectileBase> ProjectileClass;
    UPROPERTY(Category="Projectile Settings")
    USoundBase FireSound;

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        FVector location = GetActorLocation();
        FVector target(HorizontalSpeed, 0.f, 0.f);
        FVector TargetLocation = location + target;

        if (FMath::Abs(TargetLocation.X) < 500.f )
        {
            FHitResult SweepResult;
            SetActorLocation(TargetLocation, true, SweepResult, false);
        }
        else
        {
            if(System::IsValid(Movement))
            {
                // Player does not have Movement component
                Movement.SwitchDirection();
            }
        }
    }

    UFUNCTION(NotBlueprintCallable)
    void PrimaryFire()
    {
        if (ProjectileClass.IsValid())
        {
            UClass cls = ProjectileClass.Get();
            TArray<AActor> projectiles;
            Gameplay::GetAllActorsOfClass(cls, projectiles);

            if (projectiles.Num() >= 2)
            {
                // Limit number of projectiles for both player and enemy
                return;
            }

            FVector location = ProjectileSpawn.GetWorldLocation();
            Gameplay::PlaySoundAtLocation(FireSound, location, FRotator::ZeroRotator);
            ASpaceProjectileBase Projectile = Cast<ASpaceProjectileBase>(SpawnActor(cls, location, bDeferredSpawn = true));
            Projectile.SetInstigator(this);
            FinishSpawningActor(Projectile);
        }
    }

    UFUNCTION(BlueprintOverride)
    void AnyDamage(float Damage, const UDamageType DamageType, AController InstigatedBy,
                   AActor DamageCauser)
    {
        ASpaceProjectileBase projectile = Cast<ASpaceProjectileBase>(DamageCauser);
        if (projectile.ProjectileType == this.RespondsToDamageBy){
            projectile.DestroyActor();
            Health -= Damage;
            if (Health <= 0.f)
            {
                DestroyActor();

            }
        }

    }
};
