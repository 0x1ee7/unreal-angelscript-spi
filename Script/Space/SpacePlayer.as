import Space.SpaceActorBase;
import SpaceGameMode;

class SpacePlayerCharacter: ASpaceActorBase
{
    private SpaceGameMode GameMode;

    private    FTimerHandle FireTimerHandle;
    private    float VDeltaSeconds;
    private    float Speed = 2.f;

    private float MaxHealth = 300.f;
    default Health = MaxHealth;

    UPROPERTY(DefaultComponent)
    UInputComponent ScriptInputComponent;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        GameMode = Cast<SpaceGameMode>(Gameplay::GetGameMode());

        ScriptInputComponent.BindAction(n"Fire", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnFirePressed"));
        ScriptInputComponent.BindAction(n"Fire", EInputEvent::IE_Released, FInputActionHandlerDynamicSignature(this, n"OnFireReleased"));

        ScriptInputComponent.BindAxis(n"MoveRight", FInputAxisHandlerDynamicSignature(this, n"OnMoveRightAxisChanged"));
    }

    UFUNCTION()
    void OnFirePressed(FKey Key)
    {
        PrimaryFire();
        FireTimerHandle = System::SetTimer(this, n"PrimaryFire", 0.2f, true);
    }

    UFUNCTION()
    void OnFireReleased(FKey Key)
    {
        System::ClearAndInvalidateTimerHandle(FireTimerHandle);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        VDeltaSeconds = DeltaSeconds;
        FRotator rotation = GetActorRotation();
        FRotator TargetRotator(0.f,  HorizontalSpeed * -10.f, 0.f);

        FRotator DeltaRotation = FMath::RInterpConstantTo(rotation, TargetRotator, DeltaSeconds, 80.f);
        SetActorRotation(DeltaRotation);

        Super::Tick(DeltaSeconds);
    }

    void HorizontalMove(float Direction)
    {
        HorizontalSpeed = FMath::FInterpConstantTo(HorizontalSpeed, Direction * Speed, VDeltaSeconds, 6.0f);
    }

    UFUNCTION()
    void OnMoveRightAxisChanged(float AxisValue)
    {
        HorizontalMove(AxisValue);
    }

    UFUNCTION(BlueprintOverride)
    void AnyDamage(float Damage, const UDamageType DamageType, AController InstigatedBy,
                   AActor DamageCauser)
    {
        auto TGameMode = GameMode;
        Super::AnyDamage(Damage, DamageType, InstigatedBy, DamageCauser);
        TGameMode.HealthEvent.Broadcast(Health / MaxHealth);
        if (Health <= 0.f)
        {
            TGameMode.Gameover();
        }
    }
};
