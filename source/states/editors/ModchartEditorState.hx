package states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.ui.FlxButton; // Solo usamos el botón normal y nativo
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import backend.Paths;
import backend.Mods;
import backend.ClientPrefs;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

class ModchartEditorState extends MusicBeatState
{
    // --- UI BASICS ---
    var uiBox:FlxSprite;
    var titleText:FlxText;
    var valueDisplay:FlxText;
    var pageText:FlxText;

    // --- STRUMS Y PREVIEW ---
    var testStrums:FlxTypedGroup<FlxSprite>;
    var selectedStrum:Int = 4;
    var timeElapsed:Float = 0; // Para previsualizar efectos matemáticos en tiempo real

    // --- VARIABLES POR FLECHA (Estáticas) ---
    var strumX:Array<Float> = [0,0,0,0, 0,0,0,0];
    var strumY:Array<Float> = [0,0,0,0, 0,0,0,0];
    var strumAlpha:Array<Float> = [1,1,1,1, 1,1,1,1];
    var strumAngle:Array<Float> = [0,0,0,0, 0,0,0,0];
    var strumScaleX:Array<Float> = [1,1,1,1, 1,1,1,1];
    var strumScaleY:Array<Float> = [1,1,1,1, 1,1,1,1];

    // --- VARIABLES GLOBALES DE EFECTOS (Movimiento Continuo) ---
    var globalDrunk:Float = 0; // Movimiento en onda horizontal (X)
    var globalTipsy:Float = 0; // Movimiento en onda vertical (Y)
    var globalSpin:Float = 0; // Rotación constante

    // --- SISTEMA DE PÁGINAS PARA MÓVIL ---
    var currentPage:Int = 0;
    var maxPages:Int = 2; // 0: Básicos, 1: Escalas, 2: Efectos Globales
    var uiElements:FlxTypedGroup<FlxGroup>; // Grupos de UI por página

    override function create()
    {
        #if mobile
        FlxG.mouse.visible = true;
        #end

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFF0A0A1A; // Fondo un poco más oscuro
        bg.scrollFactor.set();
        add(bg);

        // --- 1. GENERACIÓN DE STRUMS ---
        testStrums = new FlxTypedGroup<FlxSprite>();
        add(testStrums);

        var arrowDirs:Array<String> = ['left', 'down', 'up', 'right'];
        for (i in 0...8) {
            var isPlayer:Bool = (i >= 4);
            var targetX:Float = isPlayer ? 732 + ((i - 4) * 112) : 92 + (i * 112);
            var strum:FlxSprite = new FlxSprite(targetX, 50);
            strum.frames = Paths.getSparrowAtlas('NOTE_assets');
            strum.animation.addByPrefix('static', 'arrow' + arrowDirs[i % 4].toUpperCase());
            strum.animation.play('static');
            strum.setGraphicSize(Std.int(strum.width * 0.7));
            strum.updateHitbox();
            strum.antialiasing = ClientPrefs.data.antialiasing;
            strum.ID = i;
            testStrums.add(strum);
        }

        // --- 2. DISEÑO DEL PANEL UI ---
        uiBox = new FlxSprite(450, 150).makeGraphic(400, 550, FlxColor.BLACK);
        uiBox.alpha = 0.95;
        uiBox.scrollFactor.set();
        add(uiBox);

        titleText = new FlxText(uiBox.x + 10, uiBox.y + 10, 380, "", 16);
        titleText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.YELLOW, CENTER);
        add(titleText);

        valueDisplay = new FlxText(uiBox.x + 20, uiBox.y + 55, 360, "", 14);
        valueDisplay.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.CYAN);
        add(valueDisplay);

        // --- 3. SISTEMA DINÁMICO DE PÁGINAS ---
        uiElements = new FlxTypedGroup<FlxGroup>();
        add(uiElements);
        
        for (i in 0...3) { // Crear 3 grupos vacíos
            uiElements.add(new FlxGroup());
        }

        // PÁGINA 0: Posición y Básicos
        addTweakToPage(0, "Mover X (Individual)", 180, function(v) { strumX[selectedStrum] += v; }, 10);
        addTweakToPage(0, "Mover Y (Individual)", 260, function(v) { strumY[selectedStrum] += v; }, 10);
        addTweakToPage(0, "Transparencia (Alpha)", 340, function(v) { strumAlpha[selectedStrum] = FlxMath.bound(strumAlpha[selectedStrum] + v, 0, 1); }, 0.1);
        addTweakToPage(0, "Ángulo Estático", 420, function(v) { strumAngle[selectedStrum] += v; }, 15);

        // PÁGINA 1: Transformaciones Avanzadas (Escalas)
        addTweakToPage(1, "Escala Ancho (X)", 180, function(v) { strumScaleX[selectedStrum] = Math.max(0.1, strumScaleX[selectedStrum] + v); }, 0.1);
        addTweakToPage(1, "Escala Alto (Y)", 260, function(v) { strumScaleY[selectedStrum] = Math.max(0.1, strumScaleY[selectedStrum] + v); }, 0.1);

        // PÁGINA 2: EFECTOS DE MOVIMIENTO (Matemáticos Globales)
        addTweakToPage(2, "Efecto 'Drunk' (Onda X)", 180, function(v) { globalDrunk += v; }, 10);
        addTweakToPage(2, "Efecto 'Tipsy' (Onda Y)", 260, function(v) { globalTipsy += v; }, 10);
        addTweakToPage(2, "Velocidad de Spin", 340, function(v) { globalSpin += v; }, 2);

        // Controles de Navegación de Páginas
        pageText = new FlxText(uiBox.x + 150, uiBox.y + 140, 100, "Pág: 1", 16);
        pageText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER);
        add(pageText);

        var btnPrev = new FlxButton(uiBox.x + 20, uiBox.y + 135, "< Atrás", function() { changePage(-1); });
        var btnNext = new FlxButton(uiBox.x + 280, uiBox.y + 135, "Sig >", function() { changePage(1); });
        
        // Damos tamaño con makeGraphic en vez de resize
        btnPrev.makeGraphic(80, 30, 0xFF444444); btnPrev.label.color = FlxColor.WHITE;
        btnNext.makeGraphic(80, 30, 0xFF444444); btnNext.label.color = FlxColor.WHITE;
        add(btnPrev); add(btnNext);

        // Botones Inferiores (Exportar y Reset)
        var exportBtn = new FlxButton(uiBox.x + 20, uiBox.y + 500, "GENERAR LUA", function() { exportToUltimateLua(); });
        exportBtn.makeGraphic(170, 35, FlxColor.LIME);
        exportBtn.label.color = FlxColor.BLACK;
        add(exportBtn);

        var resetBtn = new FlxButton(uiBox.x + 210, uiBox.y + 500, "RESET TODO", function() { resetAll(); });
        resetBtn.makeGraphic(170, 35, FlxColor.RED);
        resetBtn.label.color = FlxColor.WHITE;
        add(resetBtn);

        var closeButton = new FlxButton(uiBox.x + 365, uiBox.y + 10, "X", function() { MusicBeatState.switchState(new states.editors.MasterEditorMenu()); });
        closeButton.makeGraphic(25, 25, FlxColor.RED);
        closeButton.label.color = FlxColor.WHITE;
        add(closeButton);

        changePage(0); // Inicializar página
        updateUI();
        super.create();
    }

    // --- CONSTRUCTOR DE LA INTERFAZ ---
    function addTweakToPage(pageIndex:Int, label:String, yPos:Float, changeFunc:Float->Void, step:Float) {
        var grp = uiElements.members[pageIndex];

        var txt = new FlxText(uiBox.x + 20, uiBox.y + yPos, 360, label, 14);
        txt.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE);
        grp.add(txt);

        var btnMinus = new FlxButton(uiBox.x + 20, uiBox.y + yPos + 22, "- Menos", function() { changeFunc(-step); updateUI(); });
        var btnPlus = new FlxButton(uiBox.x + 220, uiBox.y + yPos + 22, "+ Más", function() { changeFunc(step); updateUI(); });
        
        // Ajustamos tamaño usando gráficas sólidas grises
        btnMinus.makeGraphic(160, 35, 0xFF444444);
        btnMinus.label.color = FlxColor.WHITE;
        
        btnPlus.makeGraphic(160, 35, 0xFF444444);
        btnPlus.label.color = FlxColor.WHITE;
        
        grp.add(btnMinus);
        grp.add(btnPlus);
    }

    function changePage(change:Int) {
        currentPage = FlxMath.wrap(currentPage + change, 0, maxPages);

        for (i in 0...uiElements.members.length) {
            uiElements.members[i].visible = (i == currentPage);
            uiElements.members[i].active = (i == currentPage);
        }
        pageText.text = "Pág: " + (currentPage + 1);
        updateUI();
    }

    function updateUI() {
        var strName:String = (selectedStrum >= 4) ?
            "BF [" + (selectedStrum - 4) + "]" : "DAD [" + selectedStrum + "]";

        titleText.text = "ULTIMATE MODCHART EDITOR\nSelección: " + strName;

        if (currentPage == 0) {
            valueDisplay.text = "Offsets Estáticos\nX: " + strumX[selectedStrum] + " | Y: " + strumY[selectedStrum] + "\nAlpha: " + strumAlpha[selectedStrum] + " | Ángulo: " + strumAngle[selectedStrum] + "°";
        } else if (currentPage == 1) {
            valueDisplay.text = "Escalas y Tamaño\nEscala X: " + strumScaleX[selectedStrum] + "\nEscala Y: " + strumScaleY[selectedStrum];
        } else if (currentPage == 2) {
            valueDisplay.text = "Efectos Globales (Afecta a todas)\nDrunk (Onda X): " + globalDrunk + "\nTipsy (Onda Y): " + globalTipsy + "\nSpin (Velocidad): " + globalSpin;
        }
    }

    function resetAll() {
        for(i in 0...8) {
            strumX[i] = 0;
            strumY[i] = 0;
            strumAlpha[i] = 1; strumAngle[i] = 0;
            strumScaleX[i] = 1; strumScaleY[i] = 1;
        }
        globalDrunk = 0; globalTipsy = 0; globalSpin = 0;
        updateUI();
    }

    // --- LOOP PRINCIPAL Y RENDERIZADO EN TIEMPO REAL ---
    override function update(elapsed:Float)
    {
        super.update(elapsed);

        timeElapsed += elapsed; // Reloj interno para los efectos

        // Detección táctil directa de flechas
        if (FlxG.mouse.justPressed) {
            for (strum in testStrums.members) {
                if (FlxG.mouse.overlaps(strum)) {
                    selectedStrum = strum.ID;
                    updateUI();
                    break;
                }
            }
        }

        // MOTOR DE PREVISUALIZACIÓN DE EFECTOS
        for (i in 0...8) {
            var isPlayer:Bool = (i >= 4);
            var baseDefaultX:Float = isPlayer ? 732 + ((i - 4) * 112) : 92 + (i * 112);
            var strum = testStrums.members[i];
            
            if (strum != null) {
                // Cálculo de matemáticas en tiempo real
                var mathX = Math.sin(timeElapsed * 2 + i) * globalDrunk;
                var mathY = Math.cos(timeElapsed * 2 + i) * globalTipsy;
                var mathAngle = (timeElapsed * 100 * globalSpin);

                strum.x = baseDefaultX + strumX[i] + mathX;
                strum.y = 50 + strumY[i] + mathY;
                strum.alpha = strumAlpha[i];
                strum.angle = strumAngle[i] + mathAngle;
                
                // Aplicar escala relativa al tamaño default del strum (0.7 original)
                strum.scale.x = 0.7 * strumScaleX[i];
                strum.scale.y = 0.7 * strumScaleY[i];
            }
        }

        if (controls.BACK) {
            MusicBeatState.switchState(new states.editors.MasterEditorMenu());
        }
    }

    // --- MOTOR DE GENERACIÓN LUA AVANZADO ---
    function exportToUltimateLua() {
        var luaContent:String = "-- Ultimate Modchart Generated by Psych Engine Mobile Editor\n";

        // 1. Valores estáticos en onCreatePost
        luaContent += "\nfunction onCreatePost()\n";
        for (i in 0...8) {
            var group:String = (i >= 4) ?
                "playerStrums" : "opponentStrums";
            var id:Int = (i >= 4) ? (i - 4) : i;

            if (strumAlpha[i] != 1) luaContent += "    setPropertyFromGroup('" + group + "', " + id + ", 'alpha', " + strumAlpha[i] + ")\n";
            if (strumScaleX[i] != 1) luaContent += "    setPropertyFromGroup('" + group + "', " + id + ", 'scale.x', getPropertyFromGroup('" + group + "', " + id + ", 'scale.x') * " + strumScaleX[i] + ")\n";
            if (strumScaleY[i] != 1) luaContent += "    setPropertyFromGroup('" + group + "', " + id + ", 'scale.y', getPropertyFromGroup('" + group + "', " + id + ", 'scale.y') * " + strumScaleY[i] + ")\n";
        }
        luaContent += "end\n";

        // 2. Loop de matemáticas en onUpdate (Efectos Dinámicos)
        luaContent += "\nfunction onUpdate(elapsed)\n";
        luaContent += "    local currentBeat = (getSongPosition() / 1000) * (bpm/60)\n";
        luaContent += "    local songPos = getSongPosition() / 1000\n\n";

        for (i in 0...8) {
            var group:String = (i >= 4) ?
                "playerStrums" : "opponentStrums";
            var id:Int = (i >= 4) ? (i - 4) : i;

            var defaultXStr:String = "default" + (i >= 4 ? "Player" : "Opponent") + "StrumX" + id;
            var defaultYStr:String = "default" + (i >= 4 ? "Player" : "Opponent") + "StrumY" + id;

            // Ensamblar la ecuación de X
            var eqX:String = defaultXStr + " + " + strumX[i];
            if (globalDrunk != 0) eqX += " + (math.sin(songPos * 2 + " + i + ") * " + globalDrunk + ")";
            luaContent += "    setPropertyFromGroup('" + group + "', " + id + ", 'x', " + eqX + ")\n";

            // Ensamblar la ecuación de Y
            var eqY:String = defaultYStr + " + " + strumY[i];
            if (globalTipsy != 0) eqY += " + (math.cos(songPos * 2 + " + i + ") * " + globalTipsy + ")";
            luaContent += "    setPropertyFromGroup('" + group + "', " + id + ", 'y', " + eqY + ")\n";

            // Ensamblar la rotación
            var eqAngle:String = "" + strumAngle[i];
            if (globalSpin != 0) eqAngle += " + (songPos * 100 * " + globalSpin + ")";

            if (strumAngle[i] != 0 || globalSpin != 0) {
                luaContent += "    setPropertyFromGroup('" + group + "', " + id + ", 'angle', " + eqAngle + ")\n";
            }
        }
        luaContent += "end\n";

        #if sys
        try {
            var folderPath:String = "mods/" + Mods.currentModDirectory + "/scripts/";
            if (!FileSystem.exists(folderPath)) FileSystem.createDirectory(folderPath);
            File.saveContent(folderPath + "ultimate_modchart.lua", luaContent);
            titleText.text = "¡EXPORTACIÓN EXITOSA!\nArchivo: scripts/ultimate_modchart.lua";
            titleText.color = FlxColor.LIME;
        } catch(e:Dynamic) {
            titleText.text = "ERROR AL GUARDAR.";
            titleText.color = FlxColor.RED;
        }
        #end
    }
}
