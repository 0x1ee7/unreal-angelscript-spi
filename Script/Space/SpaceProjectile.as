enum EProjectileType
{
    Enemy,
    Player
};

class ASpaceProjectileBase: AActor
{



    default InitialLifeSpan = 1.5f;
    UPROPERTY()
    USoundBase ExplosionSound;
    UPROPERTY()
    EProjectileType ProjectileType;
    UPROPERTY()
    float Speed = 1000.f;

    UPROPERTY(DefaultComponent, RootComponent)
    UStaticMeshComponent Mesh;
    default Mesh.bReturnMaterialOnMove = true;
    default Mesh.bTraceComplexOnMove = true;
    default Mesh.bCanEverAffectNavigation = false;
    default Mesh.CollisionProfileName = n"BlockAll";


    default Mesh.EnableGravity = false;


    UPROPERTY(DefaultComponent)
    UProjectileMovementComponent ProjectileMovement;


    default ProjectileMovement.Velocity = FVector(0.f, 0.f, 1.f);
    default ProjectileMovement.ProjectileGravityScale = 0.f;


    UFUNCTION(BlueprintOverride)
    void ConstructionScript()
    {
        ProjectileMovement.MaxSpeed = Speed;
        ProjectileMovement.InitialSpeed = Speed;
    }

    UFUNCTION(BlueprintOverride)
    void ActorBeginOverlap(AActor OtherActor)
    {
        Gameplay::PlaySoundAtLocation(ExplosionSound, OtherActor.GetActorLocation(), FRotator::ZeroRotator);

        if (this.Class == OtherActor.Class)
        {
            return;
        }
        AController controller;
        UClass cls;
        float Damage = 100.f;
        Gameplay::ApplyDamage(OtherActor, Damage, controller, this, cls);

    }

    UFUNCTION(BlueprintOverride)
    void Hit(UPrimitiveComponent MyComp, AActor Other, UPrimitiveComponent OtherComp, bool bSelfMoved,
             FVector HitLocation, FVector HitNormal, FVector NormalImpulse, FHitResult Hit)
    {
        TArray<UDestructibleComponent> Destructibles;
        Other.GetComponentsByClass(Destructibles);

        if (Destructibles.Num() == 1)
        {
            Destructibles[0].ApplyDamage(1000.f, Other.GetActorLocation(), GetActorForwardVector(), 10.f);
        }
        DestroyActor();

    }

};
