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
}

class ModchartEditorState extends MusicBeatState
{
	// ---------------------------------------------------------------
	// CONFIG / CONSTANTES
	// ---------------------------------------------------------------
	static var EASES:Array<String> = ['linear', 'sine', 'quad', 'cube', 'quart', 'quint', 'expo', 'circ', 'back', 'elastic', 'bounce', 'smoothStep', 'smootherStep'];
	static var EASE_TYPES:Array<String> = ['In', 'Out', 'InOut'];
	static var DURATION_UNITS:Array<String> = ['seconds', 'beats', 'steps'];

	static var KB_ROWS:Array<String> = ['1234567890', 'QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];

	// ---------------------------------------------------------------
	// ESTADO DEL MODCHART
	// ---------------------------------------------------------------
	var modchartName:String = 'NuevoModchart';
	var camZooming:Bool = true;
	var scrollInvertY:Bool = true;

	// strumActions[i] = lista de acciones del strum i (0-7). Todos los strums
	// comparten la MISMA cantidad de acciones (simplificacion a proposito: cada
	// "accion" es un paso de una linea de tiempo compartida, aunque cada strum
	// puede tener valores/duracion/delay/ease distintos en ese mismo paso).
	var strumActions:Array<Array<ModchartAction>> = [];
	var currentActionIndex:Int = 0;

	var selectedStrums:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7];
	var selectionMode:String = 'ALL';

	var stepCoarse:Bool = false; // false = paso fino (1 / 0.05), true = paso grueso (10 / 0.5)

	// ---------------------------------------------------------------
	// UI / VISUAL
	// ---------------------------------------------------------------
	var testStrums:FlxTypedGroup<FlxSprite>;
	var strumBaseX:Array<Float> = [];
	var strumBaseY:Array<Float> = [];
	var isDownscroll:Bool = false;

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
	var txtDurationUnit:FlxText;
	var txtEase:FlxText;
	var txtEaseType:FlxText;
	var txtStepMode:FlxText;
	var txtModName:FlxText;
	var camZoomBtn:FlxButton;
	var scrollInvertBtn:FlxButton;

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

	// ---------------------------------------------------------------
	// CREATE
	// ---------------------------------------------------------------
	override function create()
	{
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

		for (g in [tabsGroup, archivoGroup, valoresGroup, pruebaGroup, configGroup, keyboardGroup])
		{
			for (m in g.members)
			{
				if (Std.isOfType(m, FlxButton))
					centerLabel(cast m);
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
	function centerLabel(btn:FlxButton, ?fontSize:Int = 20)
	{
		if (btn == null || btn.label == null)
			return;
		btn.label.setFormat(Paths.font('vcr.ttf'), fontSize, FlxColor.WHITE, 'center');
		btn.label.fieldWidth = btn.width;
		btn.label.x = btn.x;
		btn.label.y = btn.y + (btn.height - btn.label.height) / 2;
	}

	function defaultAction():ModchartAction
	{
		return {x: 0, y: 0, angle: 0, alpha: 1, direction: 0, duration: 0, delay: 0, durationUnit: 'seconds', ease: 'linear', easeType: 'InOut'};
	}

	function copyAction(a:ModchartAction):ModchartAction
	{
		return {
			x: a.x, y: a.y, angle: a.angle, alpha: a.alpha, direction: a.direction,
			duration: a.duration, delay: a.delay, durationUnit: a.durationUnit, ease: a.ease, easeType: a.easeType
		};
	}

	// ---------------------------------------------------------------
	// PREVIEW DE STRUMS (arrastrables)
	// ---------------------------------------------------------------
	function buildStrumPreview()
	{
		testStrums = new FlxTypedGroup<FlxSprite>();
		add(testStrums);

		var arrowDirs:Array<String> = ['left', 'down', 'up', 'right'];
		for (i in 0...8)
		{
			var isPlayer:Bool = (i >= 4);
			var targetX:Float = isPlayer ? 660 + ((i - 4) * 90) : 60 + (i * 90);
			var targetY:Float = 15;

			strumBaseX.push(targetX);
			strumBaseY.push(targetY);

			var strum:FlxSprite = new FlxSprite(targetX, targetY);
			strum.frames = Paths.getSparrowAtlas('NOTE_assets');
			strum.animation.addByPrefix('static', 'arrow' + arrowDirs[i % 4].toUpperCase());
			strum.animation.play('static');
			strum.setGraphicSize(Std.int(strum.width * 0.4));
			strum.updateHitbox();
			strum.antialiasing = ClientPrefs.data.antialiasing;
			strum.ID = i;
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
			tabBtn.setGraphicSize(150, 56);
			tabBtn.updateHitbox();
			tabsGroup.add(tabBtn);
		}

		var closeButton = new FlxButton(FlxG.width - 70, 10, 'X', function() {
			stopTest();
			MusicBeatState.switchState(new states.editors.MasterEditorMenu());
		});
		closeButton.setGraphicSize(56, 56);
		closeButton.updateHitbox();
		closeButton.color = FlxColor.RED;
		add(closeButton);
		centerLabel(closeButton, 26);

		uiToggleBtn = new FlxButton(660, 130, 'Ocultar UI', function() {
			uiVisible = !uiVisible;
			uiToggleBtn.label.text = uiVisible ? 'Ocultar UI' : 'Mostrar UI';
			applyUIVisibility();
		});
		uiToggleBtn.setGraphicSize(150, 56);
		uiToggleBtn.updateHitbox();
		uiToggleBtn.color = FlxColor.ORANGE;
		add(uiToggleBtn);

		uiBox = new FlxSprite(10, 200).makeGraphic(FlxG.width - 20, FlxG.height - 230, FlxColor.BLACK);
		uiBox.alpha = 0.88;
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
		renameBtn.setGraphicSize(260, 50);
		renameBtn.updateHitbox();
		archivoGroup.add(renameBtn);

		var newBtn = new FlxButton(30, 310, 'Nuevo', newModchart);
		newBtn.setGraphicSize(180, 55);
		newBtn.updateHitbox();
		archivoGroup.add(newBtn);

		var saveBtn = new FlxButton(220, 310, 'Guardar datos', saveModchartData);
		saveBtn.setGraphicSize(220, 55);
		saveBtn.updateHitbox();
		saveBtn.color = FlxColor.BLUE;
		archivoGroup.add(saveBtn);

		var exportBtn = new FlxButton(450, 310, 'EXPORTAR .lua', exportModchart);
		exportBtn.setGraphicSize(240, 55);
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
		strumActions = [for (i in 0...8) [defaultAction()]];
		currentActionIndex = 0;
		selectPreset('ALL');
		refreshFieldsFromModel();
		setStatus('Nuevo modchart creado.');
	}

	function getModsRoot():String
	{
		var root = '';
		#if android
		root = lime.system.System.applicationStorageDirectory;
		if (root.length > 0 && !root.endsWith('/'))
			root += '/';
		#end
		return root;
	}

	function getModSubDir():String
	{
		return (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) ? (Mods.currentModDirectory + '/') : '';
	}

	function getScriptsPath():String
	{
		return getModsRoot() + 'mods/' + getModSubDir() + 'scripts/';
	}

	function getDataPath():String
	{
		return getModsRoot() + 'mods/' + getModSubDir() + 'data/modcharts/';
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
			strumActions = data.actions;
			currentActionIndex = 0;
			selectPreset('ALL');
			refreshFieldsFromModel();
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
					btn.setGraphicSize(420, 46);
					btn.updateHitbox();
					centerLabel(btn, 18);
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
				key.setGraphicSize(52, 52);
				key.updateHitbox();
				keyboardGroup.add(key);
			}
		}

		var spaceBtn = new FlxButton(80, startY + (KB_ROWS.length * 62), 'ESPACIO', function() {
			pendingName.add('_');
			updatePendingNameDisplay();
		});
		spaceBtn.setGraphicSize(220, 50);
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
		backBtn.setGraphicSize(180, 50);
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
		doneBtn.setGraphicSize(160, 50);
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
		selAllBtn.setGraphicSize(110, 46);
		selAllBtn.updateHitbox();
		valoresGroup.add(selAllBtn);

		var selDadBtn = new FlxButton(150, 215, 'DAD (Opp)', function() selectPreset('DAD'));
		selDadBtn.setGraphicSize(140, 46);
		selDadBtn.updateHitbox();
		valoresGroup.add(selDadBtn);

		var selBfBtn = new FlxButton(300, 215, 'BF (Player)', function() selectPreset('BF'));
		selBfBtn.setGraphicSize(140, 46);
		selBfBtn.updateHitbox();
		valoresGroup.add(selBfBtn);

		var resetBtn = new FlxButton(460, 215, 'Reset acción', resetSelected);
		resetBtn.setGraphicSize(160, 46);
		resetBtn.updateHitbox();
		resetBtn.color = FlxColor.RED;
		valoresGroup.add(resetBtn);

		txtSelection = new FlxText(640, 225, 380, '', 18);
		txtSelection.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.CYAN, 'left');
		valoresGroup.add(txtSelection);

		// Navegación de acciones
		var prevBtn = new FlxButton(30, 270, '< Anterior', function() {
			if (currentActionIndex > 0)
			{
				currentActionIndex--;
				refreshFieldsFromModel();
			}
		});
		prevBtn.setGraphicSize(150, 46);
		prevBtn.updateHitbox();
		valoresGroup.add(prevBtn);

		txtActionInfo = new FlxText(190, 280, 200, 'Acción 1/1', 18);
		valoresGroup.add(txtActionInfo);

		var nextBtn = new FlxButton(400, 270, 'Siguiente >', function() {
			if (currentActionIndex < strumActions[0].length - 1)
			{
				currentActionIndex++;
				refreshFieldsFromModel();
			}
		});
		nextBtn.setGraphicSize(150, 46);
		nextBtn.updateHitbox();
		valoresGroup.add(nextBtn);

		var addActionBtn = new FlxButton(560, 270, '+ Nueva acción', addAction);
		addActionBtn.setGraphicSize(180, 46);
		addActionBtn.updateHitbox();
		addActionBtn.color = FlxColor.LIME;
		addActionBtn.label.color = FlxColor.BLACK;
		valoresGroup.add(addActionBtn);

		var delActionBtn = new FlxButton(750, 270, 'Eliminar acción', removeAction);
		delActionBtn.setGraphicSize(180, 46);
		delActionBtn.updateHitbox();
		delActionBtn.color = FlxColor.RED;
		valoresGroup.add(delActionBtn);

		var stepBtn = new FlxButton(950, 270, 'Paso: fino', function() {
			stepCoarse = !stepCoarse;
			txtStepMode.text = 'Paso: ' + (stepCoarse ? 'grueso' : 'fino');
		});
		stepBtn.setGraphicSize(150, 46);
		stepBtn.updateHitbox();
		valoresGroup.add(stepBtn);
		txtStepMode = stepBtn.label;

		// Campos numéricos: X, Y, Angle, Alpha, Direction (fila 1) / Duration, Delay (fila 2)
		txtX = addNumField(valoresGroup, 30, 340, 'X', function() return posStep(), function(d) nudge('x', d));
		txtY = addNumField(valoresGroup, 230, 340, 'Y', function() return posStep(), function(d) nudge('y', d));
		txtAngle = addNumField(valoresGroup, 430, 340, 'Ángulo', function() return posStep(), function(d) nudge('angle', d));
		txtAlpha = addNumField(valoresGroup, 630, 340, 'Alpha', function() return alphaStep(), function(d) nudge('alpha', d));
		txtDirection = addNumField(valoresGroup, 830, 340, 'Dirección', function() return posStep(), function(d) nudge('direction', d));

		txtDuration = addNumField(valoresGroup, 30, 420, 'Duración', function() return timeStep(), function(d) nudge('duration', d));
		txtDelay = addNumField(valoresGroup, 230, 420, 'Delay', function() return timeStep(), function(d) nudge('delay', d));

		var unitBtn = new FlxButton(430, 440, 'Unidad: segundos', function() cycleDurationUnit(1));
		unitBtn.setGraphicSize(210, 46);
		unitBtn.updateHitbox();
		valoresGroup.add(unitBtn);
		txtDurationUnit = unitBtn.label;

		var easeBtn = new FlxButton(650, 440, 'Ease: linear', function() cycleEase(1));
		easeBtn.setGraphicSize(190, 46);
		easeBtn.updateHitbox();
		valoresGroup.add(easeBtn);
		txtEase = easeBtn.label;

		var easeTypeBtn = new FlxButton(850, 440, 'Tipo: InOut', function() cycleEaseType(1));
		easeTypeBtn.setGraphicSize(160, 46);
		easeTypeBtn.updateHitbox();
		valoresGroup.add(easeTypeBtn);
		txtEaseType = easeTypeBtn.label;

		var helpTxt = new FlxText(30, 528, FlxG.width - 60, 'Tocá y arrastrá un strum para seleccionarlo individualmente. Los cambios de esta pestaña se aplican a todos los strums seleccionados, en la acción actual.', 17);
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
		minus.setGraphicSize(44, 44);
		minus.updateHitbox();
		group.add(minus);

		var valTxt = new FlxText(x + 50, y + 28, 90, '0', 22);
		valTxt.setFormat(Paths.font('vcr.ttf'), 22, FlxColor.LIME, 'center');
		valTxt.alignment = 'center';
		group.add(valTxt);

		var plus = new FlxButton(x + 140, y + 22, '+', function() applyDelta(stepFn()));
		plus.setGraphicSize(44, 44);
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
		updateStrumHighlight();
		refreshFieldsFromModel();
	}

	function selectSingle(i:Int)
	{
		selectionMode = 'INDIVIDUAL';
		selectedStrums = [i];
		updateStrumHighlight();
		refreshFieldsFromModel();
	}

	function updateStrumHighlight()
	{
		for (i in 0...8)
			testStrums.members[i].color = (selectedStrums.indexOf(i) >= 0) ? FlxColor.CYAN : FlxColor.WHITE;
	}

	// ---------------------------------------------------------------
	// EDICIÓN DE VALORES
	// ---------------------------------------------------------------
	function clampF(v:Float, lo:Float, hi:Float):Float
		return v < lo ? lo : (v > hi ? hi : v);

	function nudge(prop:String, delta:Float)
	{
		for (i in selectedStrums)
		{
			var a = strumActions[i][currentActionIndex];
			switch (prop)
			{
				case 'x': a.x += delta;
				case 'y': a.y += delta;
				case 'angle': a.angle += delta;
				case 'alpha': a.alpha = clampF(a.alpha + delta, 0, 1);
				case 'direction': a.direction += delta;
				case 'duration': a.duration = Math.max(0, a.duration + delta);
				case 'delay': a.delay = Math.max(0, a.delay + delta);
			}
		}
		refreshFieldsFromModel();
	}

	function resetSelected()
	{
		for (i in selectedStrums)
			strumActions[i][currentActionIndex] = defaultAction();
		refreshFieldsFromModel();
	}

	function referenceAction():ModchartAction
	{
		var id = selectedStrums.length > 0 ? selectedStrums[0] : 0;
		return strumActions[id][currentActionIndex];
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
			strumActions[i][currentActionIndex].ease = newEase;
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
			strumActions[i][currentActionIndex].easeType = newType;
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
			strumActions[i][currentActionIndex].durationUnit = newUnit;
		refreshFieldsFromModel();
	}

	function addAction()
	{
		for (i in 0...8)
		{
			var copy = copyAction(strumActions[i][currentActionIndex]);
			strumActions[i].insert(currentActionIndex + 1, copy);
		}
		currentActionIndex++;
		refreshFieldsFromModel();
	}

	function removeAction()
	{
		if (strumActions[0].length <= 1)
		{
			setStatus('No se puede eliminar la única acción.');
			return;
		}
		for (i in 0...8)
			strumActions[i].splice(currentActionIndex, 1);
		if (currentActionIndex >= strumActions[0].length)
			currentActionIndex = strumActions[0].length - 1;
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
			txtDurationUnit.text = 'Unidad: ' + a.durationUnit;
			txtEase.text = 'Ease: ' + a.ease;
			txtEaseType.text = 'Tipo: ' + a.easeType;
		}
		if (txtActionInfo != null)
			txtActionInfo.text = 'Acción ' + (currentActionIndex + 1) + '/' + strumActions[0].length;
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
		playBtn.setGraphicSize(220, 60);
		playBtn.updateHitbox();
		playBtn.color = FlxColor.LIME;
		playBtn.label.color = FlxColor.BLACK;
		pruebaGroup.add(playBtn);

		var stopBtn = new FlxButton(280, 300, 'Detener', stopTest);
		stopBtn.setGraphicSize(220, 60);
		stopBtn.updateHitbox();
		stopBtn.color = FlxColor.RED;
		pruebaGroup.add(stopBtn);
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

	function runTestStep(i:Int, stepIdx:Int)
	{
		if (!testActive)
			return;
		var arr = strumActions[i];
		if (stepIdx >= arr.length)
			stepIdx = 0;
		var a = arr[stepIdx];

		var doApply = function() {
			if (!testActive)
				return;
			var tx = strumBaseX[i] + a.x;
			var ty = strumBaseY[i] + a.y;
			var spr = testStrums.members[i];
			if (a.duration > 0)
			{
				var ease = getFlxEase(a.ease, a.easeType);
				var tw = FlxTween.tween(spr, {x: tx, y: ty, angle: a.angle, alpha: a.alpha}, a.duration, {
					ease: ease,
					onComplete: function(_) {
						if (arr.length > 1)
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
				if (arr.length > 1)
				{
					var t = new FlxTimer().start(0.02, function(_) runTestStep(i, stepIdx + 1));
					testTimers.push(t);
				}
			}
		};

		if (a.delay > 0)
		{
			var t = new FlxTimer().start(a.delay, function(_) doApply());
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
			var a = strumActions[i][currentActionIndex];
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
		camZoomBtn.setGraphicSize(200, 50);
		camZoomBtn.updateHitbox();
		configGroup.add(camZoomBtn);

		var lbl2 = new FlxText(30, 340, 500, '¿Invertir posición Y si el scroll es contrario al de este modchart?', 18);
		configGroup.add(lbl2);
		scrollInvertBtn = new FlxButton(30, 375, scrollInvertY ? 'Activado' : 'Desactivado', function() {
			scrollInvertY = !scrollInvertY;
			scrollInvertBtn.label.text = scrollInvertY ? 'Activado' : 'Desactivado';
		});
		scrollInvertBtn.setGraphicSize(200, 50);
		scrollInvertBtn.updateHitbox();
		configGroup.add(scrollInvertBtn);

		var info = new FlxText(30, 450, FlxG.width - 60,
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

		if (!keyboardVisible)
		{
			// Mouse (para probar en PC)
			if (FlxG.mouse.justPressed)
			{
				for (i in 0...8)
				{
					if (FlxG.mouse.overlaps(testStrums.members[i]))
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
				if (touch.justPressed)
				{
					for (i in 0...8)
					{
						if (touch.overlaps(testStrums.members[i]))
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
				var a = strumActions[i][currentActionIndex];
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
		var a = strumActions[i][currentActionIndex];
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
					+ ', durationUnit=\'' + a.durationUnit + '\', ease=\'' + buildEaseString(a) + '\'},\n');
			}
			buf.add('\t},\n');
		}
		buf.add('}\n\n');

		buf.add('local scrollInvertY = ' + (scrollInvertY ? 'true' : 'false') + '\n');
		buf.add('local baseX, baseY = {}, {}\n');
		buf.add('local curStepIndex = {}\n');
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
		buf.add('\tif step.duration and step.duration > 0 then\n');
		buf.add('\t\tlocal dur = step.duration * unitMultiplier(step.durationUnit) / playbackRate\n');
		buf.add('\t\tlocal tag = \'modchart_' + safeName + '_strum\'..i..\'_step\'..stepIndex\n');
		buf.add('\t\tnoteTweenX(tag..\'_x\', i, targetX, dur, step.ease)\n');
		buf.add('\t\tnoteTweenY(tag..\'_y\', i, targetY, dur, step.ease)\n');
		buf.add('\t\tnoteTweenAngle(tag..\'_a\', i, step.angle, dur, step.ease)\n');
		buf.add('\t\tnoteTweenAlpha(tag..\'_al\', i, step.alpha, dur, step.ease)\n');
		buf.add('\t\tnoteTweenDirection(tag..\'_d\', i, step.direction, dur, step.ease)\n');
		buf.add('\telse\n');
		buf.add('\t\tsetProperty(\'strumLineNotes.members[\'..i..\'].x\', targetX)\n');
		buf.add('\t\tsetProperty(\'strumLineNotes.members[\'..i..\'].y\', targetY)\n');
		buf.add('\t\tsetProperty(\'strumLineNotes.members[\'..i..\'].angle\', step.angle)\n');
		buf.add('\t\tsetProperty(\'strumLineNotes.members[\'..i..\'].alpha\', step.alpha)\n');
		buf.add('\t\tsetProperty(\'strumLineNotes.members[\'..i..\'].direction\', step.direction)\n');
		buf.add('\t\tif #modchartSteps[i] > 1 then advanceModchartStep(i) end\n');
		buf.add('\tend\n');
		buf.add('end\n\n');

		buf.add('function applyModchartStep(i, stepIndex)\n');
		buf.add('\tcurStepIndex[i] = stepIndex\n');
		buf.add('\tlocal step = modchartSteps[i][stepIndex + 1]\n');
		buf.add('\tif not step then return end\n');
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

		buf.add('function advanceModchartStep(i)\n');
		buf.add('\tlocal steps = modchartSteps[i]\n');
		buf.add('\tif not steps or #steps <= 1 then return end\n');
		buf.add('\tlocal nextIdx = curStepIndex[i] + 1\n');
		buf.add('\tif nextIdx >= #steps then nextIdx = 0 end\n');
		buf.add('\tapplyModchartStep(i, nextIdx)\n');
		buf.add('end\n\n');

		buf.add('function onCreatePost()\n');
		if (!camZooming)
			buf.add('\tsetProperty(\'camZooming\', false)\n');
		buf.add('\tfor i = 0, 7 do\n');
		buf.add('\t\tbaseX[i] = getProperty(\'strumLineNotes.members[\'..i..\'].x\')\n');
		buf.add('\t\tbaseY[i] = getProperty(\'strumLineNotes.members[\'..i..\'].y\')\n');
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
