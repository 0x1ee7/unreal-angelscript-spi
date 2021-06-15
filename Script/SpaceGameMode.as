event void FUpdateHealthEvent(float Percent);
event void FUpdateScoreEvent();

class UHudWidget: UUserWidget
{
    private int VScore = 0;
    private UProgressBar Health;
    private UTextBlock Score;

    UFUNCTION()
    void RegisterComponents(UProgressBar Health, UTextBlock Score)
    {
        this.Health = Health;
        this.Score = Score;
        this.Health.SetPercent(1.f);
    }

    UFUNCTION()
    void UpdateHealth(float Percent)
    {
        this.Health.SetPercent(Percent);
    }

    UFUNCTION()
    void UpdateScore()
    {
        VScore += 100;
        this.Score.Text = FText::FromString("Score: " + VScore);
    }
};

class UGameOverWidget: UUserWidget
{
    private UButton Restart;
    private UButton Quit;
    APlayerController Player;


    UFUNCTION()
    void RegisterComponents(UButton Restart, UButton Quit)
    {
        this.Restart = Restart;
        this.Quit = Quit;

        Restart.OnClicked.AddUFunction(this, n"RestartExec");
        Quit.OnClicked.AddUFunction(this, n"QuitExec");
    }

    UFUNCTION(NotBlueprintCallable)
    void RestartExec()
    {
        Log("Restared main level");
        Gameplay::OpenLevel(n"Main");
    }

    UFUNCTION(NotBlueprintCallable)
    void QuitExec()
    {
        System::QuitGame(Player, EQuitPreference::Quit, false);
    }
};

class SpaceGameMode: AGameModeBase
{

    UPROPERTY()
    TSubclassOf<UHudWidget> Hud;
    UPROPERTY()
    TSubclassOf<UGameOverWidget> GameoverCls;

    UHudWidget HudWidget;
    UGameOverWidget GameOverWidget;

    FUpdateHealthEvent HealthEvent;
    FUpdateScoreEvent ScoreEvent;
    APlayerController Player;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        Player = Gameplay::GetPlayerController(0);
        WidgetBlueprint::SetInputMode_GameOnly(Player);
        HudWidget = Cast<UHudWidget>(WidgetBlueprint::CreateWidget(Hud, Player));
        HudWidget.AddToViewport();
        HealthEvent.AddUFunction(HudWidget, n"UpdateHealth");
        ScoreEvent.AddUFunction(HudWidget, n"UpdateScore");
    }

    void Gameover()
    {
        GameOverWidget = Cast<UGameOverWidget>(WidgetBlueprint::CreateWidget(GameoverCls, Player));
        GameOverWidget.Player = Player;
        Player.bShowMouseCursor = true;
        WidgetBlueprint::SetInputMode_UIOnlyEx(Player, InWidgetToFocus = GameOverWidget);
        GameOverWidget.AddToViewport();
    }

};
