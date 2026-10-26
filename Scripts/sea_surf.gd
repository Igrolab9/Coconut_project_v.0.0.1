# Море. Само по себе оно неподвижно — этим скриптом мы учим его "дышать".
extends MeshInstance3D

# Все настройки волны в одном месте — чтобы легко крутить и подбирать на глаз.
const TIDE_PERIOD: float = 5.0    # секунд на один полный цикл "накатил — отступил".
const RISE_HEIGHT: float = 0.10   # на сколько единиц вода приподнимается.
const LAP_REACH: float = 0.7      # на сколько вода подаётся к берегу за накат.

# Куда бежит волна (к берегу). Если море с другой стороны дорожки — поменяй знак.
const SHORE_DIRECTION: Vector3 = Vector3(0, 0, -1)

var _home_position: Vector3 = Vector3.ZERO # "спокойная" позиция моря, запоминаем на старте.

func _ready() -> void:
	_home_position = position

# _process — каждый кадр: волна должна двигаться плавно, как картинка, а не шагами физики.
func _process(_delta: float) -> void:
	var seconds: float = Time.get_ticks_msec() / 1000.0
	var phase: float = seconds / TIDE_PERIOD * TAU # TAU — полный круг в радианах (2π).
	# Несимметричная волна: накатывает бодро, отступает лениво — как настоящая.
	# Смешиваем две синусоиды разной частоты: в этом весь секрет "живости".
	var tide: float = sin(phase) * 0.7 + sin(phase * 2.0 + 1.0) * 0.3
	position = _home_position + Vector3.UP * (tide * RISE_HEIGHT) + SHORE_DIRECTION * (tide * LAP_REACH)
