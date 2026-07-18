package states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;

import backend.Paths;
import backend.Mods;
import backend.ClientPrefs;

using StringTools;

/**
 * ModchartEditorState
 * --------------------
 * Editor de Modcharts para Psych Engine 1.0.4 (Android), adaptado a Haxe nativo
 * y pensado para uso 100% táctil.
 *
 * Basado en el concepto del "LUA Modchart Editor" original de .bakugo, pero
 * reescrito como un FlxState nativo (como el Chart Editor) en vez de UI dinamica
 * generada por Lua. El motor Lua que este editor EXPORTA es propio (mas simple
 * y con menos piezas moviles que el original), pero produce el mismo tipo de
 * resultado: strums que se mueven/rotan/cambian de alpha con delays y tweens
 * encadenados, incluso en loop si hay mas de una accion.
 *
 * Solo trabaja sobre los 8 strums (0-3 Opponent, 4-7 Player/BF), que es lo que
 * realmente usa un modchart de este tipo.
 */
typedef ModchartAction = {
	var x:Float;
	var y:Float;
	var angle:Float;
	var alpha:Float;
	var direction:Float;
	var duration:Float;
	var delay:Float;
	var durationUnit:String; // 'seconds' | 'beats' | 'steps'
	var ease:String; // linear, sine, quad, cube, quart, quint, expo, circ, back, elastic, bounce, smoothStep, smootherStep
	var easeType:String; // 'In' | 'Out' | 'InOut'
	var spinSpeed:Float; // grados por segundo de giro CONTINUO mientras esta acción está activa (0 = no gira)
	var useAbsTime:Bool; // true = esperar a un minuto:segundo exacto de la canción en vez de esperar la acción anterior
	var absTime:Float; // segundos totales (ej: 1:21 = 81)
}

class ModchartEditorState extends MusicBeatState
{
	// ---------------------------------------------------------------
	// CONFIG / CONSTANTES
	// ---------------------------------------------------------------
	static var EASES:Array<String> = ['linear', 'sine', 'quad', 'cube', 'quart', 'quint', 'expo', 'circ', 'back', 'elastic', 'bounce', 'smoothStep', 'smootherStep'];
	static var EASE_TYPES:Array<String> = ['In', 'Out', 'InOut'];
	static var DURATION_UNITS:Array<String> = ['seconds', 'beats', 'steps'];
	// (antes había una franja fija para separar botones de flechas; ahora se
	// detecta overlap real contra los botones, ver pointOverAnyButton)

	static var KB_ROWS:Array<String> = ['1234567890', 'QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

	// ---------------------------------------------------------------
	// ESTADO DEL MODCHART
	// ---------------------------------------------------------------
	var modchartName:String = 'NuevoModchart';
	var camZooming:Bool = true;
	var scrollInvertY:Bool = true;
	var loopActions:Bool = true;

	// strumActions[i] = lista de acciones del strum i (0-7). Todos los strums
	// comparten la MISMA cantidad de acciones (simplificacion a proposito: cada
	// "accion" es un paso de una linea de tiempo compartida, aunque cada strum
	// puede tener valores/duracion/delay/ease distintos en ese mismo paso).
	var strumActions:Array<Array<ModchartAction>> = [];
	var currentActionIndex:Int = 0;

	var selectedStrums:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7];
	var selectionMode:String = 'ALL';
	var multiSelectMode:Bool = false;

	var stepCoarse:Bool = false; // false = paso fino (1 / 0.05), true = paso grueso (10 / 0.5)

	// ---------------------------------------------------------------
	// UI / VISUAL
	// ---------------------------------------------------------------
	var testStrums:FlxTypedGroup<FlxSprite>;
	var strumBaseX:Array<Float> = [];
	var strumBaseY:Array<Float> = [];
	var isDownscroll:Bool = false;
	var middlescrollActive:Bool = false;
	var showOpponentMid:Bool = false;
	var opponentToggleBtn:FlxButton;
	var multiSelectBtn:FlxButton;
	var strumToggleBtns:Array<FlxButton> = [];

	var uiBox:FlxSprite;
	var tabsGroup:FlxTypedGroup<FlxSprite>;
	var archivoGroup:FlxTypedGroup<FlxSprite>;
	var valoresGroup:FlxTypedGroup<FlxSprite>;
	var pruebaGroup:FlxTypedGroup<FlxSprite>;
	var configGroup:FlxTypedGroup<FlxSprite>;
	var keyboardGroup:FlxTypedGroup<FlxSprite>;
	var loadListGroup:FlxTypedGroup<FlxSprite>;

	var currentTab:String = 'Valores';
	var statusText:FlxText;
	var uiVisible:Bool = true;
	var uiToggleBtn:FlxButton;
	var closeButtonRef:FlxButton;

	// Campos de texto (solo lectura, se editan con los botones -/+)
	var txtActionInfo:FlxText;
	var txtSelection:FlxText;
	var txtX:FlxText;
	var txtY:FlxText;
	var txtAngle:FlxText;
	var txtAlpha:FlxText;
	var txtDirection:FlxText;
	var txtDuration:FlxText;
	var txtDelay:FlxText;
	var txtSpin:FlxText;
	var triggerModeBtn:FlxButton;
	var txtAbsTime:FlxText;
	var txtDurationUnit:FlxText;
	var txtEase:FlxText;
	var txtEaseType:FlxText;
	var txtStepMode:FlxText;
	var txtModName:FlxText;
	var camZoomBtn:FlxButton;
	var scrollInvertBtn:FlxButton;
	var loopBtn:FlxButton;

	// Drag / touch
	var mouseDragStrum:Int = -1;
	#if FLX_TOUCH
	var touchDragMap:Map<Int, Int> = new Map();
	#end

	// Nombre (teclado virtual)
	var keyboardVisible:Bool = false;
	var pendingName:StringBuf;

	// Prueba (test) tab
	var testActive:Bool = false;
	var testTimers:Array<FlxTimer> = [];
	var testTweens:Array<FlxTween> = [];
	var currentSongName:String = null;
	var currentSongModFolder:String = '';
	var voicesSound:FlxSound;
	var songPaused:Bool = false;
	var pauseSongBtn:FlxButton;
	var currentSongBPM:Float = 100;
	var txtCurrentSong:FlxText;
	var songListGroup:FlxTypedGroup<FlxSprite>;

	// ---------------------------------------------------------------
	// CREATE
	// ---------------------------------------------------------------
	override function create()
	{
		overlayGroup = new FlxTypedGroup<FlxText>();

		#if mobile
		FlxG.mouse.visible = true;
		#end

		isDownscroll = ClientPrefs.data.downScroll;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF1A1A2E);
		bg.scrollFactor.set();
		add(bg);

		for (i in 0...8)
			strumActions.push([defaultAction()]);

		buildStrumPreview();
		buildTopBar();
		buildArchivoTab();
		buildValoresTab();
		buildPruebaTab();
		buildConfigTab();
		buildKeyboard();

		statusText = new FlxText(20, FlxG.height - 46, FlxG.width - 40, '', 16);
		statusText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.YELLOW, 'left');
		statusText.color = FlxColor.YELLOW;
		add(statusText);

		switchTab('Valores');
		selectPreset('ALL');
		refreshFieldsFromModel();

		add(overlayGroup);

		for (g in [tabsGroup, archivoGroup, valoresGroup, pruebaGroup, configGroup, keyboardGroup])
		{
			for (m in g.members)
			{
				if (Std.isOfType(m, FlxButton))
					centerLabel(cast m, 15, g);
			}
		}
		centerLabel(uiToggleBtn);

		super.create();
	}

	/**
	 * Fuerza un tamaño de letra legible y centra el texto del botón (horizontal
	 * siempre, vertical si la versión de Flixel lo permite). El label por
	 * defecto de FlxButton queda muy chico y pegado a una esquina.
	 */
	var overlayPairs:Array<{btn:FlxButton, txt:FlxText, group:FlxTypedGroup<FlxSprite>}> = [];
	var overlayGroup:FlxTypedGroup<FlxText>;

	function pointOverAnyButton(px:Float, py:Float):Bool
	{
		function hits(b:FlxButton):Bool
			return b != null && b.visible && px >= b.x && px <= b.x + b.width && py >= b.y && py <= b.y + b.height;

		if (hits(closeButtonRef) || hits(uiToggleBtn))
			return true;

		for (g in [tabsGroup, archivoGroup, valoresGroup, pruebaGroup, configGroup, keyboardGroup, loadListGroup])
		{
			if (g == null || !g.visible)
				continue;
			for (m in g.members)
			{
				if (Std.isOfType(m, FlxButton) && hits(cast m))
					return true;
			}
		}
		return false;
	}

	function centerLabel(btn:FlxButton, ?fontSize:Int = 15, ?group:FlxTypedGroup<FlxSprite> = null)
	{
		if (btn == null)
			return;
		if (btn.label != null)
			btn.label.visible = false;
		var labelText = btn.label != null ? btn.label.text : '';
		var pair = null;
		for (p in overlayPairs)
			if (p.btn == btn)
				pair = p;
		if (pair == null)
		{
			var txt = new FlxText(btn.x, btn.y, btn.width, labelText, fontSize);
			overlayGroup.add(txt);
			pair = {btn: btn, txt: txt, group: group};
			overlayPairs.push(pair);
		}
		else if (group != null)
		{
			pair.group = group;
		}
		pair.txt.setFormat(Paths.font('vcr.ttf'), fontSize, FlxColor.WHITE, 'center');
		pair.txt.text = labelText;
		pair.txt.fieldWidth = btn.width;
		pair.txt.updateHitbox();
	}

	function defaultAction():ModchartAction
	{
		return {x: 0, y: 0, angle: 0, alpha: 1, direction: 0, duration: 0, delay: 0, durationUnit: 'seconds', ease: 'linear', easeType: 'InOut', spinSpeed: 0, useAbsTime: false, absTime: 0};
	}

	function copyAction(a:ModchartAction):ModchartAction
	{
		return {
			x: a.x, y: a.y, angle: a.angle, alpha: a.alpha, direction: a.direction,
			duration: a.duration, delay: a.delay, durationUnit: a.durationUnit, ease: a.ease, easeType: a.easeType,
			spinSpeed: a.spinSpeed, useAbsTime: a.useAbsTime, absTime: a.absTime
		};
	}

	/** Reconstruye las acciones cargadas desde un JSON viejo (o nuevo),
	 * rellenando con valores por defecto cualquier campo que no exista. */
	function normalizeActions(raw:Dynamic):Array<Array<ModchartAction>>
	{
		var result:Array<Array<ModchartAction>> = [];
		for (i in 0...8)
		{
			var arr:Array<ModchartAction> = [];
			var rawArr:Array<Dynamic> = raw[i];
			if (rawArr == null)
			{
				arr.push(defaultAction());
			}
			else
			{
				for (rawA in rawArr)
				{
					arr.push({
						x: rawA.x != null ? rawA.x : 0,
						y: rawA.y != null ? rawA.y : 0,
						angle: rawA.angle != null ? rawA.angle : 0,
						alpha: rawA.alpha != null ? rawA.alpha : 1,
						direction: rawA.direction != null ? rawA.direction : 0,
						duration: rawA.duration != null ? rawA.duration : 0,
						delay: rawA.delay != null ? rawA.delay : 0,
						durationUnit: rawA.durationUnit != null ? rawA.durationUnit : 'seconds',
						ease: rawA.ease != null ? rawA.ease : 'linear',
						easeType: rawA.easeType != null ? rawA.easeType : 'InOut',
						spinSpeed: rawA.spinSpeed != null ? rawA.spinSpeed : 0,
					useAbsTime: rawA.useAbsTime != null ? rawA.useAbsTime : false,
					absTime: rawA.absTime != null ? rawA.absTime : 0
					});
				}
			}
			result.push(arr);
		}
		return result;
	}

	// ---------------------------------------------------------------
	// PREVIEW DE STRUMS (arrastrables)
	// ---------------------------------------------------------------
	function buildStrumPreview()
	{
		testStrums = new FlxTypedGroup<FlxSprite>();
		add(testStrums);

		var arrowDirs:Array<String> = ['left', 'down', 'up', 'right'];
		var mid:Bool = ClientPrefs.data.middleScroll;
		middlescrollActive = mid;

		// Posiciones X reales que usa el juego (resolución interna 1280x720):
		// Opponent: 92, 204, 316, 428 — Player: 732, 844, 956, 1068
		// Con middlescroll, el juego corre ambas líneas -320px (STRUM_X_MIDDLESCROLL - STRUM_X).
		var opponentX:Array<Float> = [92, 204, 316, 428];
		var playerX:Array<Float> = [732, 844, 956, 1068];
		var scale:Float = FlxG.width / 1280;
		var midShift:Float = mid ? -320 * scale : 0;
		var realY:Float = (ClientPrefs.data.downScroll ? 570 : 50) * scale;

		for (i in 0...8)
		{
			var isPlayer:Bool = (i >= 4);
			var lane:Int = isPlayer ? (i - 4) : i;
			var rawX:Float = isPlayer ? playerX[lane] : opponentX[lane];
			var targetX:Float = (rawX * scale) + midShift;
			var targetY:Float = realY;

			strumBaseX.push(targetX);
			strumBaseY.push(targetY);

			var strum:FlxSprite = new FlxSprite(targetX, targetY);
			strum.frames = Paths.getSparrowAtlas('NOTE_assets');
			strum.animation.addByPrefix('static', 'arrow' + arrowDirs[i % 4].toUpperCase());
			strum.animation.play('static');
			strum.setGraphicSize(Std.int(strum.width * 0.7 * scale));
			strum.updateHitbox();
			strum.antialiasing = ClientPrefs.data.antialiasing;
			strum.ID = i;
			if (mid && !isPlayer)
				strum.visible = showOpponentMid;
			testStrums.add(strum);
		}
	}

	// ---------------------------------------------------------------
	// BARRA SUPERIOR (tabs + cerrar)
	// ---------------------------------------------------------------
	function buildTopBar()
	{
		tabsGroup = new FlxTypedGroup<FlxSprite>();
		add(tabsGroup);

		var tabs = ['Archivo', 'Valores', 'Prueba', 'Configuración'];
		for (i in 0...tabs.length)
		{
			var tabName = tabs[i];
			var tabBtn = new FlxButton(20 + (i * 160), 130, tabName, function() {
				switchTab(tabName);
			});
			tabBtn.setGraphicSize(105, 34);
			tabBtn.updateHitbox();
			tabsGroup.add(tabBtn);
		}

		var closeButton = new FlxButton(FlxG.width - 70, 10, 'X', function() {
			stopTest();
			MusicBeatState.switchState(new states.editors.MasterEditorMenu());
		});
		closeButton.setGraphicSize(34, 34);
		closeButton.updateHitbox();
		closeButton.color = FlxColor.RED;
		add(closeButton);
		centerLabel(closeButton, 26);
		closeButtonRef = closeButton;

		uiToggleBtn = new FlxButton(660, 130, 'Ocultar UI', function() {
			uiVisible = !uiVisible;
			uiToggleBtn.label.text = uiVisible ? 'Ocultar UI' : 'Mostrar UI';
			applyUIVisibility();
		});
		uiToggleBtn.setGraphicSize(105, 34);
		uiToggleBtn.updateHitbox();
		uiToggleBtn.color = FlxColor.ORANGE;
		add(uiToggleBtn);

		uiBox = new FlxSprite(60, 195).makeGraphic(FlxG.width - 120, FlxG.height - 225, FlxColor.BLACK);
		uiBox.alpha = 0.45;
		add(uiBox);
	}

	function applyUIVisibility()
	{
		uiBox.visible = uiVisible;
		tabsGroup.visible = tabsGroup.active = uiVisible;
		archivoGroup.visible = archivoGroup.active = uiVisible && (currentTab == 'Archivo');
		valoresGroup.visible = valoresGroup.active = uiVisible && (currentTab == 'Valores');
		pruebaGroup.visible = pruebaGroup.active = uiVisible && (currentTab == 'Prueba');
		configGroup.visible = configGroup.active = uiVisible && (currentTab == 'Configuración');
		loadListGroup.visible = loadListGroup.active = uiVisible && (currentTab == 'Archivo');
		if (songListGroup != null)
			songListGroup.visible = songListGroup.active = uiVisible && (currentTab == 'Prueba');
		if (statusText != null)
			statusText.visible = uiVisible;
	}

	function switchTab(tab:String)
	{
		currentTab = tab;
		applyUIVisibility();
		if (tab != 'Archivo')
			hideKeyboard();
		if (tab == 'Archivo')
			refreshLoadList();
	}

	function setStatus(msg:String)
	{
		if (statusText != null)
			statusText.text = msg;
	}

	// ---------------------------------------------------------------
	// TAB: ARCHIVO
	// ---------------------------------------------------------------
	function buildArchivoTab()
	{
		archivoGroup = new FlxTypedGroup<FlxSprite>();
		add(archivoGroup);
		loadListGroup = new FlxTypedGroup<FlxSprite>();
		add(loadListGroup);

		var lbl = new FlxText(30, 215, 400, 'Nombre del modchart:', 18);
		archivoGroup.add(lbl);

		txtModName = new FlxText(30, 245, 400, modchartName, 22);
		txtModName.color = FlxColor.LIME;
		archivoGroup.add(txtModName);

		var renameBtn = new FlxButton(440, 240, 'Renombrar (teclado)', function() {
			pendingName = new StringBuf();
			pendingName.add(modchartName);
			showKeyboard();
		});
		renameBtn.setGraphicSize(203, 39);
		renameBtn.updateHitbox();
		archivoGroup.add(renameBtn);

		var newBtn = new FlxButton(30, 310, 'Nuevo', newModchart);
		newBtn.setGraphicSize(140, 43);
		newBtn.updateHitbox();
		archivoGroup.add(newBtn);

		var saveBtn = new FlxButton(220, 310, 'Guardar datos', saveModchartData);
		saveBtn.setGraphicSize(172, 43);
		saveBtn.updateHitbox();
		saveBtn.color = FlxColor.BLUE;
		archivoGroup.add(saveBtn);

		var exportBtn = new FlxButton(450, 310, 'EXPORTAR .lua', exportModchart);
		exportBtn.setGraphicSize(187, 43);
		exportBtn.updateHitbox();
		exportBtn.color = FlxColor.LIME;
		exportBtn.label.color = FlxColor.BLACK;
		archivoGroup.add(exportBtn);

		var loadLbl = new FlxText(30, 380, 500, 'Modcharts guardados (tocar para cargar):', 18);
		loadLbl.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, 'left');
		archivoGroup.add(loadLbl);
	}

	function newModchart()
	{
		stopTest();
		modchartName = 'NuevoModchart';
		camZooming = true;
		scrollInvertY = true;
		loopActions = true;
		strumActions = [for (i in 0...8) [defaultAction()]];
		currentActionIndex = 0;
		selectPreset('ALL');
		refreshFieldsFromModel();
		refreshConfigButtons();
		setStatus('Nuevo modchart creado.');
	}

	function refreshConfigButtons()
	{
		if (camZoomBtn != null)
		{
			camZoomBtn.label.text = camZooming ? 'Activado' : 'Desactivado';
			centerLabel(camZoomBtn, 18);
		}
		if (scrollInvertBtn != null)
		{
			scrollInvertBtn.label.text = scrollInvertY ? 'Activado' : 'Desactivado';
			centerLabel(scrollInvertBtn, 18);
		}
		if (loopBtn != null)
		{
			loopBtn.label.text = loopActions ? 'Activado (loop)' : 'Desactivado (se detiene)';
			centerLabel(loopBtn, 18);
		}
	}

	function getModsRoot():String
	{
		var root = '';
		#if android
		root = '/storage/emulated/0/.modchartengine/';
		#end
		return root;
	}

	function getModSubDir():String
	{
		return (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) ? (Mods.currentModDirectory + '/') : '';
	}

	function getScriptsPath():String
	{
		#if android
		return '/storage/emulated/0/.modchartengine/modcharts/';
		#else
		return getModsRoot() + 'mods/' + getModSubDir() + 'scripts/';
		#end
	}

	function getDataPath():String
	{
		#if android
		return '/storage/emulated/0/.modchartengine/modcharts/';
		#else
		return getModsRoot() + 'mods/' + getModSubDir() + 'data/modcharts/';
		#end
	}

	function ensureDir(path:String)
	{
		#if sys
		if (!sys.FileSystem.exists(path))
			sys.FileSystem.createDirectory(path);
		#end
	}

	function saveModchartData()
	{
		#if sys
		try
		{
			var dir = getDataPath();
			ensureDir(dir);
			var data = {
				name: modchartName,
				camZooming: camZooming,
				scrollInvertY: scrollInvertY,
				loopActions: loopActions,
				actions: strumActions
			};
			sys.io.File.saveContent(dir + modchartName + '.json', haxe.Json.stringify(data));
			FlxG.sound.play(Paths.sound('confirmMenu'));
			setStatus('Guardado en: ' + dir + modchartName + '.json');
			refreshLoadList();
		}
		catch (e:Dynamic)
		{
			setStatus('Error al guardar: ' + Std.string(e));
		}
		#else
		setStatus('Guardado no soportado en esta plataforma.');
		#end
	}

	function loadModchartData(fname:String)
	{
		#if sys
		try
		{
			var dir = getDataPath();
			var content = sys.io.File.getContent(dir + fname);
			var data:Dynamic = haxe.Json.parse(content);
			modchartName = data.name;
			camZooming = data.camZooming;
			scrollInvertY = data.scrollInvertY;
			loopActions = (data.loopActions == null) ? true : data.loopActions;
			strumActions = normalizeActions(data.actions);
			currentActionIndex = 0;
			selectPreset('ALL');
			refreshFieldsFromModel();
			refreshConfigButtons();
			setStatus('Cargado: ' + fname);
		}
		catch (e:Dynamic)
		{
			setStatus('Error al cargar: ' + Std.string(e));
		}
		#end
	}

	function refreshLoadList()
	{
		for (m in loadListGroup.members)
			if (m != null)
				m.destroy();
		loadListGroup.clear();

		#if sys
		var dir = getDataPath();
		if (sys.FileSystem.exists(dir))
		{
			var files = sys.FileSystem.readDirectory(dir);
			var y = 420.0;
			for (f in files)
			{
				if (f.endsWith('.json'))
				{
					var fname = f;
					var btn = new FlxButton(30, y, fname, function() {
						loadModchartData(fname);
					});
					btn.setGraphicSize(328, 36);
					btn.updateHitbox();
					centerLabel(btn, 18, loadListGroup);
					loadListGroup.add(btn);
					y += 54;
					if (y > FlxG.height - 60)
						break;
				}
			}
		}
		#end
	}

	// ---------------------------------------------------------------
	// TECLADO VIRTUAL (solo para el nombre del modchart)
	// ---------------------------------------------------------------
	function buildKeyboard()
	{
		keyboardGroup = new FlxTypedGroup<FlxSprite>();
		add(keyboardGroup);

		var kbBg = new FlxSprite(60, 220).makeGraphic(FlxG.width - 120, 340, FlxColor.fromRGB(20, 20, 30));
		kbBg.alpha = 0.97;
		keyboardGroup.add(kbBg);

		var startY = 240.0;
		for (row in 0...KB_ROWS.length)
		{
			var rowStr = KB_ROWS[row];
			var startX = 80.0 + (row * 15);
			for (c in 0...rowStr.length)
			{
				var ch = rowStr.charAt(c);
				var key = new FlxButton(startX + (c * 58), startY + (row * 62), ch, function() {
					pendingName.add(ch);
					updatePendingNameDisplay();
				});
				key.setGraphicSize(41, 41);
				key.updateHitbox();
				keyboardGroup.add(key);
			}
		}

		var spaceBtn = new FlxButton(80, startY + (KB_ROWS.length * 62), 'ESPACIO', function() {
			pendingName.add('_');
			updatePendingNameDisplay();
		});
		spaceBtn.setGraphicSize(172, 39);
		spaceBtn.updateHitbox();
		keyboardGroup.add(spaceBtn);

		var backBtn = new FlxButton(310, startY + (KB_ROWS.length * 62), '<- Borrar', function() {
			var s = pendingName.toString();
			if (s.length > 0)
			{
				pendingName = new StringBuf();
				pendingName.add(s.substr(0, s.length - 1));
				updatePendingNameDisplay();
			}
		});
		backBtn.setGraphicSize(140, 39);
		backBtn.updateHitbox();
		backBtn.color = FlxColor.RED;
		keyboardGroup.add(backBtn);

		var doneBtn = new FlxButton(500, startY + (KB_ROWS.length * 62), 'Listo', function() {
			var s = pendingName.toString().trim();
			if (s.length > 0)
				modchartName = s;
			hideKeyboard();
			refreshFieldsFromModel();
		});
		doneBtn.setGraphicSize(125, 39);
		doneBtn.updateHitbox();
		doneBtn.color = FlxColor.LIME;
		doneBtn.label.color = FlxColor.BLACK;
		keyboardGroup.add(doneBtn);

		keyboardGroup.visible = keyboardGroup.active = false;
	}

	function updatePendingNameDisplay()
	{
		txtModName.text = pendingName.toString() + '_';
	}

	function showKeyboard()
	{
		keyboardVisible = true;
		keyboardGroup.visible = keyboardGroup.active = true;
		updatePendingNameDisplay();
	}

	function hideKeyboard()
	{
		keyboardVisible = false;
		keyboardGroup.visible = keyboardGroup.active = false;
		txtModName.text = modchartName;
	}

	// ---------------------------------------------------------------
	// TAB: VALORES
	// ---------------------------------------------------------------
	function buildValoresTab()
	{
		valoresGroup = new FlxTypedGroup<FlxSprite>();
		add(valoresGroup);

		// Selección rápida
		var selAllBtn = new FlxButton(30, 215, 'Todos', function() selectPreset('ALL'));
		selAllBtn.setGraphicSize(86, 36);
		selAllBtn.updateHitbox();
		valoresGroup.add(selAllBtn);

		var selDadBtn = new FlxButton(150, 215, 'DAD (Opp)', function() selectPreset('DAD'));
		selDadBtn.setGraphicSize(109, 36);
		selDadBtn.updateHitbox();
		valoresGroup.add(selDadBtn);

		var selBfBtn = new FlxButton(300, 215, 'BF (Player)', function() selectPreset('BF'));
		selBfBtn.setGraphicSize(109, 36);
		selBfBtn.updateHitbox();
		valoresGroup.add(selBfBtn);

		var resetBtn = new FlxButton(460, 215, 'Reset acción', resetSelected);
		resetBtn.setGraphicSize(125, 36);
		resetBtn.updateHitbox();
		resetBtn.color = FlxColor.RED;
		valoresGroup.add(resetBtn);

		multiSelectBtn = new FlxButton(600, 215, 'Multi-selección: OFF', function() {
			multiSelectMode = !multiSelectMode;
			multiSelectBtn.label.text = 'Multi-selección: ' + (multiSelectMode ? 'ON' : 'OFF');
			centerLabel(multiSelectBtn, 13);
		});
		multiSelectBtn.setGraphicSize(210, 36);
		multiSelectBtn.updateHitbox();
		multiSelectBtn.color = FlxColor.ORANGE;
		valoresGroup.add(multiSelectBtn);

		var strumLabels:Array<String> = ['Op ←', 'Op ↓', 'Op ↑', 'Op →', 'BF ←', 'BF ↓', 'BF ↑', 'BF →'];
		for (i in 0...8)
		{
			var idx = i;
			var btn = new FlxButton(30 + (i * 70), 253, strumLabels[i], function() {
				if (selectedStrums.indexOf(idx) >= 0)
				{
					if (selectedStrums.length > 1)
						selectedStrums.remove(idx);
				}
				else
					selectedStrums.push(idx);
				selectionMode = 'MANUAL';
				updateStrumHighlight(); refreshSelectionButtons();
				refreshSelectionButtons();
				refreshFieldsFromModel();
			});
			btn.setGraphicSize(64, 36);
			btn.updateHitbox();
			valoresGroup.add(btn);
			strumToggleBtns.push(btn);
		}

		txtSelection = new FlxText(60, 298, 380, '', 18);
		txtSelection.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.CYAN, 'left');
		valoresGroup.add(txtSelection);

		if (middlescrollActive)
		{
			opponentToggleBtn = new FlxButton(460, 298, 'Mostrar Opponent', function() {
				showOpponentMid = !showOpponentMid;
				opponentToggleBtn.label.text = showOpponentMid ? 'Ocultar Opponent' : 'Mostrar Opponent';
				centerLabel(opponentToggleBtn, 13);
				for (i in 0...4)
					testStrums.members[i].visible = showOpponentMid;
			});
			opponentToggleBtn.setGraphicSize(140, 31);
			opponentToggleBtn.updateHitbox();
			opponentToggleBtn.color = FlxColor.PURPLE;
			valoresGroup.add(opponentToggleBtn);
		}

		// Navegación de acciones
		var prevBtn = new FlxButton(30, 345, '< Anterior', function() {
			if (currentActionIndex > 0)
			{
				currentActionIndex--;
				refreshFieldsFromModel();
			}
		});
		prevBtn.setGraphicSize(117, 36);
		prevBtn.updateHitbox();
		valoresGroup.add(prevBtn);

		txtActionInfo = new FlxText(190, 355, 200, 'Acción 1/1', 18);
		valoresGroup.add(txtActionInfo);

		var nextBtn = new FlxButton(400, 345, 'Siguiente >', function() {
			if (currentActionIndex < strumActions[refStrumId()].length - 1)
			{
				currentActionIndex++;
				refreshFieldsFromModel();
			}
		});
		nextBtn.setGraphicSize(117, 36);
		nextBtn.updateHitbox();
		valoresGroup.add(nextBtn);

		var addActionBtn = new FlxButton(560, 345, '+ Nueva acción', addAction);
		addActionBtn.setGraphicSize(140, 36);
		addActionBtn.updateHitbox();
		addActionBtn.color = FlxColor.LIME;
		addActionBtn.label.color = FlxColor.BLACK;
		valoresGroup.add(addActionBtn);

		var delActionBtn = new FlxButton(750, 345, 'Eliminar acción', removeAction);
		delActionBtn.setGraphicSize(140, 36);
		delActionBtn.updateHitbox();
		delActionBtn.color = FlxColor.RED;
		valoresGroup.add(delActionBtn);

		var stepBtn = new FlxButton(950, 345, 'Paso: fino', function() {
			stepCoarse = !stepCoarse;
			txtStepMode.text = 'Paso: ' + (stepCoarse ? 'grueso' : 'fino');
		});
		stepBtn.setGraphicSize(117, 36);
		stepBtn.updateHitbox();
		valoresGroup.add(stepBtn);
		txtStepMode = stepBtn.label;

		var returnBtn = new FlxButton(30, 395, '↩ Volver al inicio (nueva acción)', addReturnAction);
		returnBtn.setGraphicSize(250, 31);
		returnBtn.updateHitbox();
		returnBtn.color = FlxColor.CYAN;
		returnBtn.label.color = FlxColor.BLACK;
		valoresGroup.add(returnBtn);

		// Campos numéricos: X, Y, Angle, Alpha, Direction (fila 1) / Duration, Delay (fila 2)
		txtX = addNumField(valoresGroup, 30, 453, 'X', function() return posStep(), function(d) nudge('x', d));
		txtY = addNumField(valoresGroup, 230, 453, 'Y', function() return posStep(), function(d) nudge('y', d));
		txtAngle = addNumField(valoresGroup, 430, 453, 'Ángulo', function() return posStep(), function(d) nudge('angle', d));
		txtAlpha = addNumField(valoresGroup, 630, 453, 'Alpha', function() return alphaStep(), function(d) nudge('alpha', d));
		txtDirection = addNumField(valoresGroup, 830, 453, 'Dirección', function() return posStep(), function(d) nudge('direction', d));

		txtDuration = addNumField(valoresGroup, 30, 533, 'Duración', function() return timeStep(), function(d) nudge('duration', d));
		txtDelay = addNumField(valoresGroup, 230, 533, 'Delay', function() return timeStep(), function(d) nudge('delay', d));
		txtSpin = addNumField(valoresGroup, 630, 533, 'Giro °/seg', function() return posStep() * 9, function(d) nudge('spinSpeed', d));

		triggerModeBtn = new FlxButton(30, 578, 'Disparo: Secuencial', function() {
			var newVal = !referenceAction().useAbsTime;
			for (i in selectedStrums)
				strumActions[i][safeIdx(i)].useAbsTime = newVal;
			triggerModeBtn.label.text = 'Disparo: ' + (newVal ? 'Tiempo fijo' : 'Secuencial');
			centerLabel(triggerModeBtn, 15);
			refreshFieldsFromModel();
		});
		triggerModeBtn.setGraphicSize(220, 38);
		triggerModeBtn.updateHitbox();
		triggerModeBtn.color = FlxColor.PURPLE;
		valoresGroup.add(triggerModeBtn);

		txtAbsTime = addNumField(valoresGroup, 270, 578, 'Tiempo (mm:ss)', function() return stepCoarse ? 10 : 1, function(d) nudge('absTime', d));

		var useNowBtn = new FlxButton(470, 578, 'Usar tiempo actual', function() {
			if (FlxG.sound.music == null)
			{
				setStatus('No hay ninguna canción sonando para tomar el tiempo.');
				return;
			}
			var secs = FlxG.sound.music.time / 1000;
			for (i in selectedStrums)
				strumActions[i][safeIdx(i)].absTime = secs;
			refreshFieldsFromModel();
			setStatus('Tiempo tomado: ' + formatSongTime(FlxG.sound.music.time));
		});
		useNowBtn.setGraphicSize(210, 38);
		useNowBtn.updateHitbox();
		useNowBtn.color = FlxColor.CYAN;
		useNowBtn.label.color = FlxColor.BLACK;
		valoresGroup.add(useNowBtn);

		var unitBtn = new FlxButton(30, 668, 'Unidad: segundos', function() cycleDurationUnit(1));
		unitBtn.setGraphicSize(164, 36);
		unitBtn.updateHitbox();
		valoresGroup.add(unitBtn);
		txtDurationUnit = unitBtn.label;

		var easeBtn = new FlxButton(250, 668, 'Ease: linear', function() cycleEase(1));
		easeBtn.setGraphicSize(148, 36);
		easeBtn.updateHitbox();
		valoresGroup.add(easeBtn);
		txtEase = easeBtn.label;

		var easeTypeBtn = new FlxButton(470, 668, 'Tipo: InOut', function() cycleEaseType(1));
		easeTypeBtn.setGraphicSize(125, 36);
		easeTypeBtn.updateHitbox();
		valoresGroup.add(easeTypeBtn);
		txtEaseType = easeTypeBtn.label;

		var helpTxt = new FlxText(30, 728, FlxG.width - 60, 'Los cambios se aplican a los strums seleccionados, en la acción actual.', 15);
		helpTxt.setFormat(Paths.font('vcr.ttf'), 17, FlxColor.GRAY, 'left');
		helpTxt.color = FlxColor.GRAY;
		valoresGroup.add(helpTxt);
	}

	function posStep():Float
		return stepCoarse ? 10 : 1;

	function alphaStep():Float
		return stepCoarse ? 0.25 : 0.05;

	function timeStep():Float
		return stepCoarse ? 0.5 : 0.05;

	/**
	 * Crea un campo numérico de solo-lectura con botones -/+ a los costados.
	 * Devuelve el FlxText donde se muestra el valor (para poder refrescarlo).
	 */
	function addNumField(group:FlxTypedGroup<FlxSprite>, x:Float, y:Float, labelStr:String, stepFn:Void->Float, applyDelta:Float->Void):FlxText
	{
		var lbl = new FlxText(x, y, 180, labelStr, 18);
		lbl.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, 'left');
		group.add(lbl);

		var minus = new FlxButton(x, y + 22, '-', function() applyDelta(-stepFn()));
		minus.setGraphicSize(34, 34);
		minus.updateHitbox();
		group.add(minus);

		var valTxt = new FlxText(x + 50, y + 28, 90, '0', 22);
		valTxt.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.LIME, 'center');
		valTxt.alignment = 'center';
		group.add(valTxt);

		var plus = new FlxButton(x + 140, y + 22, '+', function() applyDelta(stepFn()));
		plus.setGraphicSize(34, 34);
		plus.updateHitbox();
		group.add(plus);

		return valTxt;
	}

	// ---------------------------------------------------------------
	// SELECCIÓN
	// ---------------------------------------------------------------
	function selectPreset(mode:String)
	{
		selectionMode = mode;
		selectedStrums = [];
		for (i in 0...8)
		{
			if (mode == 'ALL')
				selectedStrums.push(i);
			else if (mode == 'DAD' && i < 4)
				selectedStrums.push(i);
			else if (mode == 'BF' && i >= 4)
				selectedStrums.push(i);
		}
		updateStrumHighlight(); refreshSelectionButtons();
		refreshFieldsFromModel();
	}

	function selectSingle(i:Int)
	{
		if (multiSelectMode)
		{
			selectionMode = 'MÚLTIPLE';
			if (selectedStrums.indexOf(i) >= 0)
			{
				if (selectedStrums.length > 1)
					selectedStrums.remove(i);
			}
			else
				selectedStrums.push(i);
		}
		else
		{
			selectionMode = 'INDIVIDUAL';
			selectedStrums = [i];
		}
		updateStrumHighlight(); refreshSelectionButtons();
		refreshFieldsFromModel();
	}

	function updateStrumHighlight()
	{
		for (i in 0...8)
			testStrums.members[i].color = (selectedStrums.indexOf(i) >= 0) ? FlxColor.CYAN : FlxColor.WHITE;
	}

	function refreshSelectionButtons()
	{
		for (i in 0...strumToggleBtns.length)
			strumToggleBtns[i].color = (selectedStrums.indexOf(i) >= 0) ? FlxColor.LIME : FlxColor.GRAY;
	}

	/**
	 * Con middlescroll activado, por defecto solo se ven/editan las flechas
	 * del Player (como en el juego real); las de Opponent quedan escondidas
	 * hasta que se activan con el botón "Mostrar Opponent".
	 */
	// ---------------------------------------------------------------
	// EDICIÓN DE VALORES
	// ---------------------------------------------------------------
	function clampF(v:Float, lo:Float, hi:Float):Float
		return v < lo ? lo : (v > hi ? hi : v);

	function nudge(prop:String, delta:Float)
	{
		for (i in selectedStrums)
		{
			var a = strumActions[i][safeIdx(i)];
			switch (prop)
			{
				case 'x': a.x += delta;
				case 'y': a.y += delta;
				case 'angle': a.angle += delta;
				case 'alpha': a.alpha = clampF(a.alpha + delta, 0, 1);
				case 'direction': a.direction += delta;
				case 'duration': a.duration = Math.max(0, a.duration + delta);
				case 'delay': a.delay = Math.max(0, a.delay + delta);
				case 'absTime': a.absTime = Math.max(0, a.absTime + delta);
				case 'spinSpeed': a.spinSpeed += delta;
			}
		}
		refreshFieldsFromModel();
	}

	function resetSelected()
	{
		for (i in selectedStrums)
			strumActions[i][safeIdx(i)] = defaultAction();
		refreshFieldsFromModel();
	}

	function referenceAction():ModchartAction
	{
		var id = refStrumId();
		return strumActions[id][safeIdx(id)];
	}

	function refStrumId():Int
	{
		return selectedStrums.length > 0 ? selectedStrums[0] : 0;
	}

	/** Índice de acción seguro para un strum en particular (puede tener menos
	 * acciones que el strum de referencia, ahora que cada uno puede tener su
	 * propia cantidad de pasos). */
	function safeIdx(i:Int):Int
	{
		return Std.int(Math.min(currentActionIndex, strumActions[i].length - 1));
	}

	function cycleEase(dir:Int)
	{
		var cur = referenceAction().ease;
		var idx = EASES.indexOf(cur);
		if (idx < 0)
			idx = 0;
		idx = (idx + dir + EASES.length) % EASES.length;
		var newEase = EASES[idx];
		for (i in selectedStrums)
			strumActions[i][safeIdx(i)].ease = newEase;
		refreshFieldsFromModel();
	}

	function cycleEaseType(dir:Int)
	{
		var cur = referenceAction().easeType;
		var idx = EASE_TYPES.indexOf(cur);
		if (idx < 0)
			idx = 0;
		idx = (idx + dir + EASE_TYPES.length) % EASE_TYPES.length;
		var newType = EASE_TYPES[idx];
		for (i in selectedStrums)
			strumActions[i][safeIdx(i)].easeType = newType;
		refreshFieldsFromModel();
	}

	function cycleDurationUnit(dir:Int)
	{
		var cur = referenceAction().durationUnit;
		var idx = DURATION_UNITS.indexOf(cur);
		if (idx < 0)
			idx = 0;
		idx = (idx + dir + DURATION_UNITS.length) % DURATION_UNITS.length;
		var newUnit = DURATION_UNITS[idx];
		for (i in selectedStrums)
			strumActions[i][safeIdx(i)].durationUnit = newUnit;
		refreshFieldsFromModel();
	}

	function addAction()
	{
		for (i in selectedStrums)
		{
			var copy = copyAction(strumActions[i][currentActionIndex < strumActions[i].length ? currentActionIndex : strumActions[i].length - 1]);
			var insertAt = Std.int(Math.min(currentActionIndex + 1, strumActions[i].length));
			strumActions[i].insert(insertAt, copy);
		}
		currentActionIndex++;
		refreshFieldsFromModel();
	}

	/** Agrega una acción igual a los valores por defecto (0,0,0,alpha 1) al final,
	 * para que la flecha vuelva sola a su posición original. */
	function addReturnAction()
	{
		for (i in selectedStrums)
			strumActions[i].push(defaultAction());
		currentActionIndex = strumActions[refStrumId()].length - 1;
		refreshFieldsFromModel();
		setStatus('Se agregó una acción de "vuelta al inicio" para los strums seleccionados.');
	}

	function removeAction()
	{
		var refLen = strumActions[refStrumId()].length;
		if (refLen <= 1)
		{
			setStatus('No se puede eliminar la única acción.');
			return;
		}
		for (i in selectedStrums)
		{
			if (currentActionIndex < strumActions[i].length)
				strumActions[i].splice(currentActionIndex, 1);
		}
		if (currentActionIndex >= strumActions[refStrumId()].length)
			currentActionIndex = strumActions[refStrumId()].length - 1;
		refreshFieldsFromModel();
	}

	function refreshFieldsFromModel()
	{
		var a = referenceAction();
		if (txtX != null)
		{
			txtX.text = Std.string(Math.round(a.x));
			txtY.text = Std.string(Math.round(a.y));
			txtAngle.text = Std.string(Math.round(a.angle));
			txtAlpha.text = Std.string(Math.round(a.alpha * 100) / 100);
			txtDirection.text = Std.string(Math.round(a.direction));
			txtDuration.text = Std.string(Math.round(a.duration * 100) / 100);
			txtDelay.text = Std.string(Math.round(a.delay * 100) / 100);
			txtSpin.text = Std.string(Math.round(a.spinSpeed));
			txtAbsTime.text = formatSongTime(a.absTime * 1000);
			if (triggerModeBtn != null)
			{
				triggerModeBtn.label.text = 'Disparo: ' + (a.useAbsTime ? 'Tiempo fijo' : 'Secuencial');
				centerLabel(triggerModeBtn, 15);
			}
			txtDurationUnit.text = 'Unidad: ' + a.durationUnit;
			txtEase.text = 'Ease: ' + a.ease;
			txtEaseType.text = 'Tipo: ' + a.easeType;
		}
		if (txtActionInfo != null)
			txtActionInfo.text = 'Acción ' + (currentActionIndex + 1) + '/' + strumActions[refStrumId()].length;
		if (txtSelection != null)
			txtSelection.text = 'Selección: ' + selectionMode + ' (' + selectedStrums.length + ' strums)';
		if (txtModName != null && !keyboardVisible)
			txtModName.text = modchartName;
	}

	// ---------------------------------------------------------------
	// TAB: PRUEBA (preview en vivo, no escribe el .lua)
	// ---------------------------------------------------------------
	function buildPruebaTab()
	{
		pruebaGroup = new FlxTypedGroup<FlxSprite>();
		add(pruebaGroup);

		var helpTxt = new FlxText(30, 220, FlxG.width - 60,
			'Reproduce en vivo la secuencia de acciones de los strums seleccionados (arriba, en la pestaña Valores), para probar antes de exportar.', 16);
		pruebaGroup.add(helpTxt);

		var playBtn = new FlxButton(30, 300, 'Reproducir', startTest);
		playBtn.setGraphicSize(172, 47);
		playBtn.updateHitbox();
		playBtn.color = FlxColor.LIME;
		playBtn.label.color = FlxColor.BLACK;
		pruebaGroup.add(playBtn);

		var stopBtn = new FlxButton(280, 300, 'Detener', stopTest);
		stopBtn.setGraphicSize(172, 47);
		stopBtn.updateHitbox();
		stopBtn.color = FlxColor.RED;
		pruebaGroup.add(stopBtn);

		var songLbl = new FlxText(30, 370, 500, 'Canción de fondo (para probar con música real):', 17);
		pruebaGroup.add(songLbl);

		var chooseSongBtn = new FlxButton(30, 405, 'Elegir canción', function() {
			refreshSongList();
		});
		chooseSongBtn.setGraphicSize(200, 42);
		chooseSongBtn.updateHitbox();
		chooseSongBtn.color = FlxColor.CYAN;
		chooseSongBtn.label.color = FlxColor.BLACK;
		pruebaGroup.add(chooseSongBtn);

		var playSongBtn = new FlxButton(240, 405, 'Reproducir canción', function() {
			if (currentSongName != null)
				playCurrentSong();
			else
				setStatus('Primero elegí una canción de la lista.');
		});
		playSongBtn.setGraphicSize(200, 42);
		playSongBtn.updateHitbox();
		playSongBtn.color = FlxColor.LIME;
		playSongBtn.label.color = FlxColor.BLACK;
		pruebaGroup.add(playSongBtn);

		var stopSongBtn = new FlxButton(450, 405, 'Detener canción', function() {
			FlxG.sound.music.stop();
			if (voicesSound != null)
				voicesSound.stop();
			songPaused = false;
			setStatus('Canción detenida.');
		});
		stopSongBtn.setGraphicSize(200, 42);
		stopSongBtn.updateHitbox();
		stopSongBtn.color = FlxColor.RED;
		pruebaGroup.add(stopSongBtn);

		pauseSongBtn = new FlxButton(30, 450, 'Pausar', pauseResumeSong);
		pauseSongBtn.setGraphicSize(150, 40);
		pauseSongBtn.updateHitbox();
		pauseSongBtn.color = FlxColor.YELLOW;
		pauseSongBtn.label.color = FlxColor.BLACK;
		pruebaGroup.add(pauseSongBtn);

		var backBtn = new FlxButton(190, 450, '<< -5s', function() seekSong(-5));
		backBtn.setGraphicSize(110, 40);
		backBtn.updateHitbox();
		pruebaGroup.add(backBtn);

		var fwdBtn = new FlxButton(310, 450, '+5s >>', function() seekSong(5));
		fwdBtn.setGraphicSize(110, 40);
		fwdBtn.updateHitbox();
		pruebaGroup.add(fwdBtn);

		var resetSongBtn = new FlxButton(430, 450, 'Reiniciar (0:00)', resetSong);
		resetSongBtn.setGraphicSize(180, 40);
		resetSongBtn.updateHitbox();
		resetSongBtn.color = FlxColor.ORANGE;
		pruebaGroup.add(resetSongBtn);

		txtCurrentSong = new FlxText(30, 500, 620, 'Canción: (ninguna) — BPM: 100', 16);
		txtCurrentSong.color = FlxColor.YELLOW;
		pruebaGroup.add(txtCurrentSong);

		songListGroup = new FlxTypedGroup<FlxSprite>();
		add(songListGroup);
	}

	function getSongsPath():String
	{
		return getModsRoot() + 'mods/' + getModSubDir() + 'songs/';
	}

	function refreshSongList()
	{
		for (m in songListGroup.members)
			if (m != null)
				m.destroy();
		songListGroup.clear();

		#if sys
		var modsRoot = getModsRoot() + 'mods/';
		var candidateDirs:Array<String> = []; // songsPath -> modFolder (guardado paralelo)
		var candidateMods:Array<String> = [];

		if (getModSubDir().length > 0)
		{
			candidateDirs.push(modsRoot + getModSubDir() + 'songs/');
			candidateMods.push(getModSubDir());
		}

		// mods/songs/ directo, sin carpeta de mod
		candidateDirs.push(modsRoot + 'songs/');
		candidateMods.push('');

		if (sys.FileSystem.exists(modsRoot))
		{
			for (folder in sys.FileSystem.readDirectory(modsRoot))
			{
				if (!sys.FileSystem.isDirectory(modsRoot + folder))
					continue;
				var p = modsRoot + folder + '/songs/';
				var already = false;
				for (c in candidateDirs)
					if (c == p)
						already = true;
				if (!already && sys.FileSystem.exists(p))
				{
					candidateDirs.push(p);
					candidateMods.push(folder + '/');
				}
			}
		}

		var y = 535.0;
		var totalFound = 0;
		for (ci in 0...candidateDirs.length)
		{
			var dir = candidateDirs[ci];
			var modFolder = candidateMods[ci];
			if (!sys.FileSystem.exists(dir))
				continue;
			for (f in sys.FileSystem.readDirectory(dir))
			{
				if (!sys.FileSystem.isDirectory(dir + f))
					continue;
				var songName = f;
				var songMod = modFolder;
				var btn = new FlxButton(30, y, songName, function() {
					selectSong(songName, songMod);
				});
				btn.setGraphicSize(300, 38);
				btn.updateHitbox();
				centerLabel(btn, 16, pruebaGroup);
				songListGroup.add(btn);
				y += 42;
				totalFound++;
				if (y > FlxG.height - 60)
					break;
			}
		}
		if (totalFound == 0)
			setStatus('No encontré ninguna carpeta songs/ con canciones en mods/.');
		else
			setStatus('Encontré ' + totalFound + ' canción(es).');
		#end
	}

	function selectSong(songName:String, songMod:String)
	{
		currentSongName = songName;
		currentSongModFolder = songMod;
		currentSongBPM = 100;
		#if sys
		try
		{
			var dataPath = getModsRoot() + 'mods/' + songMod + 'data/' + songName + '/' + songName + '.json';
			if (sys.FileSystem.exists(dataPath))
			{
				var data:Dynamic = haxe.Json.parse(sys.io.File.getContent(dataPath));
				var songData:Dynamic = data.song != null ? data.song : data;
				if (songData.bpm != null)
					currentSongBPM = songData.bpm;
			}
		}
		catch (e:Dynamic) {}
		#end
		txtCurrentSong.text = 'Canción: ' + currentSongName + ' — BPM: ' + currentSongBPM;
		setStatus('Canción seleccionada: ' + songName);
		playCurrentSong();
	}

	function playCurrentSong()
	{
		if (currentSongName == null)
			return;
		try
		{
			FlxG.sound.playMusic(Paths.inst(currentSongName), 1, true);
			if (voicesSound != null)
			{
				voicesSound.stop();
				voicesSound.destroy();
				voicesSound = null;
			}
			voicesSound = FlxG.sound.load(Paths.voices(currentSongName), 1, true);
			if (voicesSound != null)
				voicesSound.play();
			songPaused = false;
			if (pauseSongBtn != null)
			{
				pauseSongBtn.label.text = 'Pausar';
				centerLabel(pauseSongBtn, 18);
			}
		}
		catch (e:Dynamic)
		{
			setStatus('No pude reproducir esa canción (¿le faltan Inst.ogg / Voices.ogg?).');
		}
	}

	function pauseResumeSong()
	{
		if (FlxG.sound.music == null)
		{
			setStatus('No hay ninguna canción sonando.');
			return;
		}
		songPaused = !songPaused;
		if (songPaused)
		{
			FlxG.sound.music.pause();
			if (voicesSound != null)
				voicesSound.pause();
			setStatus('Canción pausada en ' + formatSongTime(FlxG.sound.music.time));
		}
		else
		{
			FlxG.sound.music.resume();
			if (voicesSound != null)
				voicesSound.resume();
			setStatus('Canción reanudada.');
		}
		pauseSongBtn.label.text = songPaused ? 'Reanudar' : 'Pausar';
		centerLabel(pauseSongBtn, 18);
	}

	function seekSong(deltaSeconds:Float)
	{
		if (FlxG.sound.music == null)
			return;
		var newTime = Math.max(0, FlxG.sound.music.time + (deltaSeconds * 1000));
		FlxG.sound.music.time = newTime;
		if (voicesSound != null)
			voicesSound.time = newTime;
		setStatus('Canción en ' + formatSongTime(newTime));
	}

	function resetSong()
	{
		if (FlxG.sound.music == null)
			return;
		FlxG.sound.music.time = 0;
		if (voicesSound != null)
			voicesSound.time = 0;
		setStatus('Canción reiniciada (0:00).');
	}

	function formatSongTime(ms:Float):String
	{
		var totalSec = Std.int(ms / 1000);
		var min = Std.int(totalSec / 60);
		var sec = totalSec % 60;
		return min + ':' + (sec < 10 ? '0' : '') + sec;
	}

	function startTest()
	{
		stopTest();
		testActive = true;
		for (i in 0...8)
		{
			FlxTween.cancelTweensOf(testStrums.members[i]);
			runTestStep(i, 0);
		}
		setStatus('Reproduciendo prueba (los 8 strums)...');
	}

	function unitToSeconds(amount:Float, unit:String):Float
	{
		var crochet = 60 / currentSongBPM;
		return switch (unit)
		{
			case 'beats': amount * crochet;
			case 'steps': amount * (crochet / 4);
			default: amount;
		}
	}

	function runTestStep(i:Int, stepIdx:Int)
	{
		if (!testActive)
			return;
		var arr = strumActions[i];
		if (stepIdx >= arr.length)
			stepIdx = 0;
		var a = arr[stepIdx];
		var durSec = unitToSeconds(a.duration, a.durationUnit);
		var delaySec = unitToSeconds(a.delay, a.durationUnit);

		var doApply = function() {
			if (!testActive)
				return;
			var tx = strumBaseX[i] + a.x;
			var ty = strumBaseY[i] + a.y;
			var spr = testStrums.members[i];
			if (durSec > 0)
			{
				var ease = getFlxEase(a.ease, a.easeType);
				var tw = FlxTween.tween(spr, {x: tx, y: ty, angle: a.angle, alpha: a.alpha}, durSec, {
					ease: ease,
					onComplete: function(_) {
						if (arr.length > 1 && (loopActions || stepIdx + 1 < arr.length))
							runTestStep(i, stepIdx + 1);
					}
				});
				testTweens.push(tw);
			}
			else
			{
				spr.x = tx;
				spr.y = ty;
				spr.angle = a.angle;
				spr.alpha = a.alpha;
				if (arr.length > 1 && (loopActions || stepIdx + 1 < arr.length))
				{
					var t = new FlxTimer().start(0.02, function(_) runTestStep(i, stepIdx + 1));
					testTimers.push(t);
				}
			}
		};

		if (a.useAbsTime)
		{
			var t = new FlxTimer();
			t.start(0.05, function(tmr) {
				if (!testActive)
				{
					tmr.cancel();
					return;
				}
				if (FlxG.sound.music != null && FlxG.sound.music.time >= a.absTime * 1000)
				{
					tmr.cancel();
					doApply();
				}
			}, 0);
			testTimers.push(t);
		}
		else if (delaySec > 0)
		{
			var t = new FlxTimer().start(delaySec, function(_) doApply());
			testTimers.push(t);
		}
		else
			doApply();
	}

	function stopTest()
	{
		testActive = false;
		for (t in testTimers)
			t.cancel();
		testTimers = [];
		for (tw in testTweens)
			if (tw != null)
				tw.cancel();
		testTweens = [];
		for (i in 0...8)
		{
			var a = strumActions[i][safeIdx(i)];
			var spr = testStrums.members[i];
			spr.x = strumBaseX[i] + a.x;
			spr.y = strumBaseY[i] + a.y;
			spr.angle = a.angle;
			spr.alpha = a.alpha;
		}
		setStatus('');
	}

	function getFlxEase(base:String, type:String):Float->Float
	{
		return switch (base)
		{
			case 'sine': type == 'In' ? FlxEase.sineIn : (type == 'Out' ? FlxEase.sineOut : FlxEase.sineInOut);
			case 'quad': type == 'In' ? FlxEase.quadIn : (type == 'Out' ? FlxEase.quadOut : FlxEase.quadInOut);
			case 'cube': type == 'In' ? FlxEase.cubeIn : (type == 'Out' ? FlxEase.cubeOut : FlxEase.cubeInOut);
			case 'quart': type == 'In' ? FlxEase.quartIn : (type == 'Out' ? FlxEase.quartOut : FlxEase.quartInOut);
			case 'quint': type == 'In' ? FlxEase.quintIn : (type == 'Out' ? FlxEase.quintOut : FlxEase.quintInOut);
			case 'expo': type == 'In' ? FlxEase.expoIn : (type == 'Out' ? FlxEase.expoOut : FlxEase.expoInOut);
			case 'circ': type == 'In' ? FlxEase.circIn : (type == 'Out' ? FlxEase.circOut : FlxEase.circInOut);
			case 'back': type == 'In' ? FlxEase.backIn : (type == 'Out' ? FlxEase.backOut : FlxEase.backInOut);
			case 'elastic': type == 'In' ? FlxEase.elasticIn : (type == 'Out' ? FlxEase.elasticOut : FlxEase.elasticInOut);
			case 'bounce': type == 'In' ? FlxEase.bounceIn : (type == 'Out' ? FlxEase.bounceOut : FlxEase.bounceInOut);
			default: FlxEase.linear; // linear, smoothStep, smootherStep -> aproximado en la vista previa
		}
	}

	// ---------------------------------------------------------------
	// TAB: CONFIGURACIÓN
	// ---------------------------------------------------------------
	function buildConfigTab()
	{
		configGroup = new FlxTypedGroup<FlxSprite>();
		add(configGroup);

		var lbl1 = new FlxText(30, 230, 500, '¿Zoom de cámara automático en cada beat?', 18);
		configGroup.add(lbl1);
		camZoomBtn = new FlxButton(30, 265, camZooming ? 'Activado' : 'Desactivado', function() {
			camZooming = !camZooming;
			camZoomBtn.label.text = camZooming ? 'Activado' : 'Desactivado';
		});
		camZoomBtn.setGraphicSize(156, 39);
		camZoomBtn.updateHitbox();
		configGroup.add(camZoomBtn);

		var lbl2 = new FlxText(30, 340, 500, '¿Invertir posición Y si el scroll es contrario al de este modchart?', 18);
		configGroup.add(lbl2);
		scrollInvertBtn = new FlxButton(30, 375, scrollInvertY ? 'Activado' : 'Desactivado', function() {
			scrollInvertY = !scrollInvertY;
			scrollInvertBtn.label.text = scrollInvertY ? 'Activado' : 'Desactivado';
		});
		scrollInvertBtn.setGraphicSize(156, 39);
		scrollInvertBtn.updateHitbox();
		configGroup.add(scrollInvertBtn);

		var lbl3 = new FlxText(30, 450, 700, '¿Al llegar a la última acción, vuelve a la acción 1 (loop)?', 18);
		configGroup.add(lbl3);
		loopBtn = new FlxButton(30, 485, loopActions ? 'Activado (loop)' : 'Desactivado (se detiene)', function() {
			loopActions = !loopActions;
			loopBtn.label.text = loopActions ? 'Activado (loop)' : 'Desactivado (se detiene)';
			centerLabel(loopBtn, 18);
		});
		loopBtn.setGraphicSize(250, 39);
		loopBtn.updateHitbox();
		configGroup.add(loopBtn);

		var info = new FlxText(30, 560, FlxG.width - 60,
			'Estas opciones se guardan junto con el modchart y también se aplican en el .lua exportado.', 15);
		info.color = FlxColor.GRAY;
		configGroup.add(info);
	}

	// ---------------------------------------------------------------
	// UPDATE (drag táctil + mouse, multitouch real)
	// ---------------------------------------------------------------
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		for (p in overlayPairs)
		{
			var groupOk = (p.group == null) || (p.group.visible && p.group.exists);
			p.txt.visible = p.btn.visible && p.btn.exists && p.btn.alive && groupOk;
			p.txt.x = p.btn.x;
			p.txt.y = p.btn.y + (p.btn.height - p.txt.height) / 2;
		}

		if (!keyboardVisible)
		{
			// Mouse (para probar en PC)
			if (FlxG.mouse.justPressed && !pointOverAnyButton(FlxG.mouse.x, FlxG.mouse.y))
			{
				for (i in 0...8)
				{
					if (testStrums.members[i].visible && FlxG.mouse.overlaps(testStrums.members[i]))
					{
						mouseDragStrum = i;
						selectSingle(i);
						break;
					}
				}
			}
			if (FlxG.mouse.pressed && mouseDragStrum >= 0)
				dragStrumTo(mouseDragStrum, FlxG.mouse.x, FlxG.mouse.y);
			if (FlxG.mouse.justReleased)
				mouseDragStrum = -1;

			#if FLX_TOUCH
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed && !pointOverAnyButton(touch.x, touch.y))
				{
					for (i in 0...8)
					{
						if (testStrums.members[i].visible && touch.overlaps(testStrums.members[i]))
						{
							touchDragMap.set(touch.touchPointID, i);
							selectSingle(i);
							break;
						}
					}
				}
				if (touch.pressed && touchDragMap.exists(touch.touchPointID))
					dragStrumTo(touchDragMap.get(touch.touchPointID), touch.x, touch.y);
				if (touch.justReleased && touchDragMap.exists(touch.touchPointID))
					touchDragMap.remove(touch.touchPointID);
			}
			#end
		}

		// Vista previa de la acción actual para los strums que no se están arrastrando
		if (!testActive)
		{
			for (i in 0...8)
			{
				if (i == mouseDragStrum)
					continue;
				#if FLX_TOUCH
				var dragging = false;
				for (v in touchDragMap)
					if (v == i)
						dragging = true;
				if (dragging)
					continue;
				#end
				var a = strumActions[i][safeIdx(i)];
				var spr = testStrums.members[i];
				spr.x = strumBaseX[i] + a.x;
				spr.y = strumBaseY[i] + a.y;
				spr.angle = a.angle;
				spr.alpha = a.alpha;
			}
		}
	}

	function dragStrumTo(i:Int, mx:Float, my:Float)
	{
		var a = strumActions[i][safeIdx(i)];
		a.x = mx - strumBaseX[i];
		a.y = my - strumBaseY[i];
		var spr = testStrums.members[i];
		spr.x = mx;
		spr.y = my;
		refreshFieldsFromModel();
	}

	// ---------------------------------------------------------------
	// EXPORTACIÓN A LUA
	// ---------------------------------------------------------------
	function sanitizeName(n:String):String
	{
		var out = new StringBuf();
		for (i in 0...n.length)
		{
			var code = n.charCodeAt(i);
			var isAlnum = (code >= 48 && code <= 57) || (code >= 65 && code <= 90) || (code >= 97 && code <= 122) || code == 95;
			out.add(isAlnum ? n.charAt(i) : '_');
		}
		var s = out.toString();
		return s.length > 0 ? s : 'modchart';
	}

	function buildEaseString(a:ModchartAction):String
	{
		if (a.ease == 'linear' || a.ease == 'smoothStep' || a.ease == 'smootherStep')
			return a.ease;
		return a.ease + a.easeType;
	}

	function buildLuaScript():String
	{
		var safeName = sanitizeName(modchartName);
		var buf = new StringBuf();

		buf.add('-- Modchart generado con el Editor de Modcharts (Haxe) para Psych Engine 1.0.4\n');
		buf.add('-- Adaptacion del concepto de LUA Modchart Editor original de .bakugo\n');
		buf.add('-- Nombre: ' + modchartName + '\n\n');

		buf.add('local modchartSteps = {\n');
		for (i in 0...8)
		{
			buf.add('\t[' + i + '] = {\n');
			for (a in strumActions[i])
			{
				buf.add('\t\t{x=' + a.x + ', y=' + a.y + ', angle=' + a.angle + ', alpha=' + a.alpha
					+ ', direction=' + a.direction + ', duration=' + a.duration + ', delay=' + a.delay
					+ ', durationUnit=\'' + a.durationUnit + '\', ease=\'' + buildEaseString(a) + '\''
					+ ', spinSpeed=' + a.spinSpeed + ', useAbsTime=' + (a.useAbsTime ? 'true' : 'false') + ', absTime=' + a.absTime + '},\n');
			}
			buf.add('\t},\n');
		}
		buf.add('}\n\n');

		buf.add('local scrollInvertY = ' + (scrollInvertY ? 'true' : 'false') + '\n');
		buf.add('local baseX, baseY, baseAngle, baseDirection = {}, {}, {}, {}\n');
		buf.add('local curStepIndex = {}\n');
		buf.add('local activeSpinSpeed = {}\n');
		buf.add('local waitingAbsTime = {}\n');
		buf.add('for i = 0, 7 do activeSpinSpeed[i] = 0 end\n');
		buf.add('for i = 0, 7 do waitingAbsTime[i] = false end\n');
		buf.add('for i = 0, 7 do curStepIndex[i] = 0 end\n\n');

		buf.add('local function unitMultiplier(unit)\n');
		buf.add('\tif unit == \'beats\' then return crochet * 0.001\n');
		buf.add('\telseif unit == \'steps\' then return stepCrochet * 0.001\n');
		buf.add('\telse return 1 end\n');
		buf.add('end\n\n');

		buf.add('local function applyModchartStepValues(i, stepIndex)\n');
		buf.add('\tlocal step = modchartSteps[i][stepIndex + 1]\n');
		buf.add('\tif not step then return end\n');
		buf.add('\tlocal yOff = step.y\n');
		buf.add('\tif scrollInvertY and downscroll then yOff = -yOff end\n');
		buf.add('\tlocal targetX = baseX[i] + step.x\n');
		buf.add('\tlocal targetY = baseY[i] + yOff\n');
		buf.add('\tlocal targetAngle = baseAngle[i] + step.angle\n');
		buf.add('\tlocal targetDirection = baseDirection[i] + step.direction\n');
		buf.add('\tif step.duration and step.duration > 0 then\n');
		buf.add('\t\tlocal dur = step.duration * unitMultiplier(step.durationUnit) / playbackRate\n');
		buf.add('\t\tlocal tag = \'modchart_' + safeName + '_strum\'..i..\'_step\'..stepIndex\n');
		buf.add('\t\tnoteTweenX(tag..\'_x\', i, targetX, dur, step.ease)\n');
		buf.add('\t\tnoteTweenY(tag..\'_y\', i, targetY, dur, step.ease)\n');
		buf.add('\t\tif not step.spinSpeed or step.spinSpeed == 0 then\n');
		buf.add('\t\t\tnoteTweenAngle(tag..\'_a\', i, targetAngle, dur, step.ease)\n');
		buf.add('\t\tend\n');
		buf.add('\t\tnoteTweenAlpha(tag..\'_al\', i, step.alpha, dur, step.ease)\n');
		buf.add('\t\tnoteTweenDirection(tag..\'_d\', i, targetDirection, dur, step.ease)\n');
		buf.add('\telse\n');
		buf.add('\t\tsetPropertyFromGroup(\'strumLineNotes\', i, \'x\', targetX)\n');
		buf.add('\t\tsetPropertyFromGroup(\'strumLineNotes\', i, \'y\', targetY)\n');
		buf.add('\t\tif not step.spinSpeed or step.spinSpeed == 0 then\n');
		buf.add('\t\t\tsetPropertyFromGroup(\'strumLineNotes\', i, \'angle\', targetAngle)\n');
		buf.add('\t\tend\n');
		buf.add('\t\tsetPropertyFromGroup(\'strumLineNotes\', i, \'alpha\', step.alpha)\n');
		buf.add('\t\tsetPropertyFromGroup(\'strumLineNotes\', i, \'direction\', targetDirection)\n');
		buf.add('\t\tif #modchartSteps[i] > 1 then advanceModchartStep(i) end\n');
		buf.add('\tend\n');
		buf.add('end\n\n');

		buf.add('function applyModchartStep(i, stepIndex)\n');
		buf.add('\tcurStepIndex[i] = stepIndex\n');
		buf.add('\tlocal step = modchartSteps[i][stepIndex + 1]\n');
		buf.add('\tif not step then return end\n');
		buf.add('\tactiveSpinSpeed[i] = step.spinSpeed or 0\n');
		buf.add('\tif step.useAbsTime then\n');
		buf.add('\t\twaitingAbsTime[i] = true\n');
		buf.add('\t\treturn\n');
		buf.add('\tend\n');
		buf.add('\tif step.delay and step.delay > 0 then\n');
		buf.add('\t\tlocal dur = step.delay * unitMultiplier(step.durationUnit) / playbackRate\n');
		buf.add('\t\truntimerTag_' + safeName + '(i, stepIndex, dur)\n');
		buf.add('\telse\n');
		buf.add('\t\tapplyModchartStepValues(i, stepIndex)\n');
		buf.add('\tend\n');
		buf.add('end\n\n');

		buf.add('function runtimerTag_' + safeName + '(i, stepIndex, dur)\n');
		buf.add('\trunTimer(\'modchart_' + safeName + '_strum\'..i..\'_delay\'..stepIndex, dur)\n');
		buf.add('end\n\n');

		buf.add('local loopActions = ' + (loopActions ? 'true' : 'false') + '\n');
		buf.add('function advanceModchartStep(i)\n');
		buf.add('\tlocal steps = modchartSteps[i]\n');
		buf.add('\tif not steps or #steps <= 1 then return end\n');
		buf.add('\tlocal nextIdx = curStepIndex[i] + 1\n');
		buf.add('\tif nextIdx >= #steps then\n');
		buf.add('\t\tif not loopActions then return end\n');
		buf.add('\t\tnextIdx = 0\n');
		buf.add('\tend\n');
		buf.add('\tapplyModchartStep(i, nextIdx)\n');
		buf.add('end\n\n');

		buf.add('function onCreatePost()\n');
		if (!camZooming)
			buf.add('\tsetProperty(\'camZooming\', false)\n');
		buf.add('\tlocal authoredMiddlescroll = ' + (ClientPrefs.data.middleScroll ? 'true' : 'false') + '\n');
		buf.add('\tif middleScroll ~= authoredMiddlescroll then\n');
		buf.add('\t\tsetPropertyFromClass(\'backend.ClientPrefs\', \'data.middleScroll\', authoredMiddlescroll)\n');
		buf.add('\tend\n');
		buf.add('\tfor i = 0, 7 do\n');
		buf.add('\t\tbaseX[i] = getPropertyFromGroup(\'strumLineNotes\', i, \'x\')\n');
		buf.add('\t\tbaseY[i] = getPropertyFromGroup(\'strumLineNotes\', i, \'y\')\n');
		buf.add('\t\tbaseAngle[i] = getPropertyFromGroup(\'strumLineNotes\', i, \'angle\')\n');
		buf.add('\t\tbaseDirection[i] = getPropertyFromGroup(\'strumLineNotes\', i, \'direction\')\n');
		buf.add('\t\tapplyModchartStep(i, 0)\n');
		buf.add('\tend\n');
		buf.add('end\n\n');

		buf.add('function onTweenCompleted(tag)\n');
		buf.add('\tlocal i = tonumber(tag:match(\'^modchart_' + safeName + '_strum(%d+)_step%d+_x$\'))\n');
		buf.add('\tif i ~= nil then advanceModchartStep(i) end\n');
		buf.add('end\n\n');

		buf.add('function onTimerCompleted(tag, loops, loopsLeft)\n');
		buf.add('\tlocal i, stepStr = tag:match(\'^modchart_' + safeName + '_strum(%d+)_delay(%d+)$\')\n');
		buf.add('\tif i ~= nil then applyModchartStepValues(tonumber(i), tonumber(stepStr)) end\n');
		buf.add('end\n\n');

		buf.add('function update(elapsed)\n');
		buf.add('\tfor i = 0, 7 do\n');
		buf.add('\t\tif activeSpinSpeed[i] and activeSpinSpeed[i] ~= 0 then\n');
		buf.add('\t\t\tlocal cur = getPropertyFromGroup(\'strumLineNotes\', i, \'angle\')\n');
		buf.add('\t\t\tsetPropertyFromGroup(\'strumLineNotes\', i, \'angle\', cur + (activeSpinSpeed[i] * elapsed))\n');
		buf.add('\t\tend\n');
		buf.add('\t\tif waitingAbsTime[i] then\n');
		buf.add('\t\t\tlocal step = modchartSteps[i][curStepIndex[i] + 1]\n');
		buf.add('\t\t\tif step and getSongPosition() >= (step.absTime or 0) * 1000 then\n');
		buf.add('\t\t\t\twaitingAbsTime[i] = false\n');
		buf.add('\t\t\t\tapplyModchartStepValues(i, curStepIndex[i])\n');
		buf.add('\t\t\tend\n');
		buf.add('\t\tend\n');
		buf.add('\tend\n');
		buf.add('end\n');

		return buf.toString();
	}

	function exportModchart()
	{
		#if sys
		try
		{
			var dir = getScriptsPath();
			ensureDir(dir);
			var lua = buildLuaScript();
			var safeName = sanitizeName(modchartName);
			sys.io.File.saveContent(dir + safeName + '.lua', lua);
			FlxG.sound.play(Paths.sound('confirmMenu'));
			setStatus('Exportado en: ' + dir + safeName + '.lua');
		}
		catch (e:Dynamic)
		{
			setStatus('Error al exportar: ' + Std.string(e));
		}
		#else
		setStatus('Exportación no soportada en esta plataforma.');
		#end
	}
}
