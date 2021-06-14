import Space.SpaceEnemy;

UCLASS(Abstract)
class AEnemyPack: AActor
{
    private     int numEnemies = 55;
    private     int numRows = 5;
    private     float spacing = 40.f;


    UPROPERTY()
    AEnemyMovement Movement;

    UPROPERTY()
    TSubclassOf<SpaceEnemy> EnemyClass;
    TArray<SpaceEnemy> FiringSquad;
    TArray<SpaceEnemy> AllEnemies;


    UFUNCTION(BlueprintOverride)
    void ConstructionScript()
    {
        Movement = AEnemyMovement::Create(this);
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {

        System::SetTimer(this, n"PauseMovement", 1.f,true);

        if(EnemyClass.IsValid())
        {
            FVector location = GetActorLocation();
            for(int i = 0; i < numEnemies; i++){
                float row = i % numRows;
                float col = i / numRows;
                FVector space(col * spacing, 0.f, row * spacing);
                SpaceEnemy Enemy = Cast<SpaceEnemy>(SpawnActor(EnemyClass.Get(), location + space, bDeferredSpawn = true));
                Enemy.Movement = Movement;
                if(row == 0){
                    Enemy.squadId = col + 1;
                    FiringSquad.Add(Enemy);
                    BindEvents(Enemy);

                }
                AllEnemies.Add(Enemy);
                FinishSpawningActor(Enemy);
            }
        }

    }

    UFUNCTION(NotBlueprintCallable)
    void PauseMovement()
    {
        Movement.Pause();
    }

    UFUNCTION()
    void SquadFire(int squadId)
    {

        SpaceEnemy FiringMember = FiringSquad[squadId - 1];
        if(System::IsValid(FiringMember))
        {
            FiringMember.PrimaryFire();
        }
    }



    UFUNCTION()
    void SquadUpdate(int squadId)
    {
        int enemyID = squadId - 1;
        SpaceEnemy NextEnemy;
        for (int i = 1; i < numRows; i++)
        {
            NextEnemy = AllEnemies[enemyID * numRows + i];

            if(System::IsValid(NextEnemy) && !NextEnemy.IsActorBeingDestroyed())
            {
                NextEnemy.squadId = squadId;
                BindEvents(NextEnemy);
                FiringSquad[enemyID] = NextEnemy;
                return;
            }
        }

    }

    void BindEvents(SpaceEnemy Enemy)
    {
        Enemy.UpdateGunship.AddUFunction(this, n"SquadUpdate");
        Enemy.FireEvent.AddUFunction(this, n"SquadFire");
    }

};
