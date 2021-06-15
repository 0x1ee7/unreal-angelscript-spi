import Space.SpaceActorBase;
import SpaceGameMode;

event void FEnemyFireEvent(int squadId);
event void FSquadUpdateEvent(int squadId);
class SpaceEnemy: ASpaceActorBase
{
    int squadId = 0;

    private SpaceGameMode GameMode;

    private     bool bIsActiveFiring = true;
    private     float distanceX = 100.f;

    default ActorMesh.WorldScale3D = FVector(0.7f, 0.7f, 0.7f);
    default ProjectileSpawn.WorldLocation = FVector(0.f, 0.f, -20.f);

    FSquadUpdateEvent UpdateGunship;
    FEnemyFireEvent FireEvent;

    UPROPERTY(NotEditable, BlueprintReadOnly)
    FVector OriginalPosition;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        GameMode = Cast<SpaceGameMode>(Gameplay::GetGameMode());
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        HorizontalSpeed = Movement.Velocity();

        APawn player = Gameplay::GetPlayerPawn(0);
        if (System::IsValid(player)){
            FVector playerLocation = player.GetActorLocation();
            FVector selfLocation = GetActorLocation();
            distanceX = FMath::Abs(selfLocation.X - playerLocation.X);
        }
        else
        {
            bIsActiveFiring = false;
        }

        if (distanceX <= 2.f )
        {
            // Fire
            if(squadId != 0 && bIsActiveFiring)
            {
                FireEvent.Broadcast(squadId);
                bIsActiveFiring = false;
            }
        }
        else
        {
            bIsActiveFiring = true;
        }

        Super::Tick(DeltaSeconds);
    }

    UFUNCTION(BlueprintOverride)
    void Destroyed()
    {
        UpdateGunship.Broadcast(squadId);
        GameMode.ScoreEvent.Broadcast();
    }
};
