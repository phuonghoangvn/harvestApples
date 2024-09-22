extends Node2D


const EXPLODE = preload("res://assets/explode.mp3")


@export var apple_scene: PackedScene


@onready var label: Label = $Label
@onready var timer: Timer = $Timer
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioPlayer2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var start_popup: PopupPanel = $CanvasLayer/StartPopup
@onready var game_over_popup: PopupPanel = $CanvasLayer/GameOverPopup

var _score: int = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    timer.stop()  # Stop the timer to prevent apples from falling at the start
    show_start_popup()  # Show the start popup when the game starts

func show_start_popup() -> void:
    await get_tree().process_frame  # Wait for a frame to ensure everything is processed
    start_popup.popup_centered()

func start_game() -> void:
    _score = 0
    label.text = "%03d" % _score
    start_popup.hide()  # Hide the start popup when the game begins
    timer.start()
    spawn_apple()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass


func spawn_apple() -> void:
    var new_apple: Apple = apple_scene.instantiate()
    var xpos: float = randf_range(70, 1050)	
    new_apple.on_apple_off_screen.connect(game_over)
    new_apple.position = Vector2(xpos, -50)
    add_child(new_apple)


func stop_all() -> void:
    timer.stop()
    for child in get_children():
        child.set_process(false)


func play_dead() -> void:
    audio_stream_player_2d.stop()
    audio_stream_player_2d.stream = EXPLODE
    audio_stream_player_2d.play()


func game_over() -> void:
    stop_all()
    play_dead()
    show_game_over_popup()  # Show the game over popup
    
func show_game_over_popup() -> void:
    game_over_popup.show()
    game_over_popup.popup_centered()
    
func restart_game() -> void:
    game_over_popup.hide()  # Hide the game over popup
    reset_game()

func reset_game() -> void:
    # Reset score and other variables
    _score = 0
    label.text = "%03d" % _score

    # Remove any existing apples
    for child in get_children():
        if child is Apple:
            child.queue_free()
            
    # Re-enable processing for nodes like paddle or player
    #for child in get_children():
        #if child is Paddle:  # Replace 'Paddle' with the actual name of your node
            #child.set_process(true)


    timer.start()
    spawn_apple()

# Button signal connections
func _on_start_button_pressed() -> void:
    start_game()

func _on_restart_button_pressed() -> void:
    restart_game()


func _on_timer_timeout() -> void:
    spawn_apple() 


func _on_basket_area_entered(area: Area2D) -> void:
    _score += 1
    label.text = "%03d" % _score
    audio_stream_player_2d.position = area.position
    audio_stream_player_2d.play()
    area.queue_free()
