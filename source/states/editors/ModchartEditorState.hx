package states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import sys.FileSystem;
import sys.io.File;
import lime.app.Application; // <-- CORREGIDO: Import necesario para las alertas nativas

// Clases oficiales de Psych Engine 1.0.4
import backend.MusicBeatState;
import backend.Paths;
import backend.Controls;
import objects.Character;

using StringTools; // <-- CORREGIDO: Esto permite usar .endsWith() en los archivos JSON

class ModchartEditorState extends MusicBeatState
{
    var UI_box:FlxUITabMenu;
    
    var dad:Character;
    var boyfriend:Character;
    
    var strumSprites:FlxTypedGroup<FlxSprite>;
    var initialPositions:Array<FlxPoint> = [];
    
    var selectedStrum:Int = -1;
    var isDragging:Bool = false;
    var dragOffset:FlxPoint = new FlxPoint(0, 0);
    
    var groupMode:String = "Single"; 
    var modchartNameInput:FlxUIInputText;
    var strumAlphaStepper:FlxUINumericStepper;
    var strumAngleStepper:FlxUINumericStepper;
    var strumScaleStepper:FlxUINumericStepper;
    
    var strumAlphas:Array<Float> = [1, 1, 1, 1, 1, 1, 1, 1];
    var strumAngles:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0];
    var strumScales:Array<Float> = [0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7];
    
    var strumsData:Array<String> = ['purple', 'blue', 'green', 'red', 'purple', 'blue', 'green', 'red'];

    override function create()
    {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFF18181F;
        bg.scrollFactor.set();
        add(bg);

        var grid:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ui/grid'));
        grid.scrollFactor.set();
        grid.alpha = 0.08;
        add(grid);

        var infoTxt:FlxText = new FlxText(20, 20, 0, "Modchart Editor Visual v1.0\n[Arrastra las flechas con el dedo/mouse]", 16);
        infoTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        add(infoTxt);

        // Render de personajes principales
        dad = new Character(100, 220, 'dad', false);
        dad.scrollFactor.set();
        dad.scale.set(0.8, 0.8);
        dad.updateHitbox();
        add(dad);

        boyfriend = new Character(650, 220, 'bf', true);
        boyfriend.scrollFactor.set();
        boyfriend.scale.set(0.8, 0.8);
        boyfriend.updateHitbox();
        add(boyfriend);

        dad.playAnim('idle', true);
        boyfriend.playAnim('idle', true);

        // Generación de Flechas (Strums)
        strumSprites = new FlxTypedGroup<FlxSprite>();
        add(strumSprites);

        var targetX:Array<Float> = [92, 204, 316, 428, 732, 844, 956, 1068];
        var defaultY:Float = 80;

        for (i in 0...8)
        {
            var strum:FlxSprite = new FlxSprite(targetX[i], defaultY);
            strum.frames = Paths.getSparrowAtlas('NOTE_assets');
            strum.animation.addByPrefix('static', strumsData[i] + ' alone', 24, false);
            strum.animation.play('static');
            strum.scale.set(strumScales[i], strumScales[i]);
            strum.updateHitbox();
            strum.scrollFactor.set();
            strum.ID = i;
            
            strumSprites.add(strum);
            initialPositions.push(new FlxPoint(targetX[i], defaultY));
        }

        // Pestañas de la Interfaz
        var tabs = [
            {name: "comportamiento", label: 'Modos y Guardado'},
            {name: "transformaciones", label: 'Propiedades Nota'}
        ];

        UI_box = new FlxUITabMenu(null, tabs, true);
        UI_box.resize(320, 420);
        UI_box.x = FlxG.width - UI_box.width - 20;
        UI_box.y = 150;
        UI_box.scrollFactor.set();
        add(UI_box);

        setupComportamientoTab();
        setupTransformacionesTab();

        FlxG.mouse.visible = true;

        super.create();
    }

    function setupComportamientoTab()
    {
        var tab_box = new FlxUI(null, UI_box);
        tab_box.name = "comportamiento";

        var groupLabel = new FlxText(10, 15, 0, "Modo de Selección / Arrastre:", 10);
        var modesArray:Array<String> = ["Single", "Opponent Group", "Player Group", "All Mixed"];
        
        var groupDropDown = new FlxUIDropDownMenu(10, 30, FlxUIDropDownMenu.makeStrIdLabelArray(modesArray, true), function(selected:String) {
            switch(Std.parseInt(selected)) {
                case 0: groupMode = "Single";
                case 1: groupMode = "Opponent";
                case 2: groupMode = "Player";
                case 3: groupMode = "All";
            }
        });
        groupDropDown.selectedLabel = "Single";

        var nameLabel = new FlxText(10, 100, 0, "Nombre Script (.lua):", 10);
        modchartNameInput = new FlxUIInputText(10, 115, 200, "custom_modchart", 12);

        var saveBtn = new FlxButton(10, 180, "Exportar Código Lua", function() {
            exportModchartLua();
        });
        saveBtn.resize(180, 30);

        var resetBtn = new FlxButton(10, 230, "Resetear Posiciones", function() {
            for (i in 0...8) {
                strumSprites.members[i].x = initialPositions[i].x;
                strumSprites.members[i].y = initialPositions[i].y;
            }
        });
        resetBtn.resize(180, 30);

        tab_box.add(groupLabel);
        tab_box.add(groupDropDown);
        tab_box.add(nameLabel);
        tab_box.add(modchartNameInput);
        tab_box.add(saveBtn);
        tab_box.add(resetBtn);

        UI_box.addGroup(tab_box);
    }

    function setupTransformacionesTab()
    {
        var tab_box = new FlxUI(null, UI_box);
        tab_box.name = "transformaciones";

        var alphaLabel = new FlxText(10, 15, 0, "Opacidad (Alpha) de Nota:", 10);
        strumAlphaStepper = new FlxUINumericStepper(10, 30, 0.1, 1.0, 0.0, 1.0, 1);
        
        var angleLabel = new FlxText(10, 80, 0, "Rotación (Ángulo):", 10);
        strumAngleStepper = new FlxUINumericStepper(10, 95, 5, 0, -360, 360, 0);

        var scaleLabel = new FlxText(10, 150, 0, "Tamaño (Escala):", 10);
        strumScaleStepper = new FlxUINumericStepper(10, 165, 0.05, 0.7, 0.1, 2.0, 2);

        var applyTransformBtn = new FlxButton(10, 230, "Aplicar a Selección", function() {
            updateNodeTransforms();
        });
        applyTransformBtn.resize(180, 30);

        tab_box.add(alphaLabel);
        tab_box.add(strumAlphaStepper);
        tab_box.add(angleLabel);
        tab_box.add(strumAngleStepper);
        tab_box.add(scaleLabel);
        tab_box.add(strumScaleStepper);
        tab_box.add(applyTransformBtn);

        UI_box.addGroup(tab_box);
    }

    function updateNodeTransforms()
    {
        var targetIDs:Array<Int> = getAffectedStrums(selectedStrum);
        
        for (id in targetIDs) {
            strumAlphas[id] = strumAlphaStepper.value;
            strumAngles[id] = strumAngleStepper.value;
            strumScales[id] = strumScaleStepper.value;
            
            var spr = strumSprites.members[id];
            spr.alpha = strumAlphas[id];
            spr.angle = strumAngles[id];
            spr.scale.set(strumScales[id], strumScales[id]);
        }
    }

    function getAffectedStrums(current:Int):Array<Int>
    {
        var list:Array<Int> = [];
        if (current == -1) {
            if (groupMode == "Opponent") return [0, 1, 2, 3];
            if (groupMode == "Player") return [4, 5, 6, 7];
            if (groupMode == "All") return [0, 1, 2, 3, 4, 5, 6, 7];
            return [0];
        }
        
        switch(groupMode) {
            case "Single":
                list.push(current);
            case "Opponent":
                list = [0, 1, 2, 3];
            case "Player":
                list = [4, 5, 6, 7];
            case "All":
                list = [0, 1, 2, 3, 4, 5, 6, 7];
        }
        return list;
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (dad.animation.curAnim.finished) dad.playAnim('idle');
        if (boyfriend.animation.curAnim.finished) boyfriend.playAnim('idle');

        var pointerX:Float = FlxG.mouse.x;
        var pointerY:Float = FlxG.mouse.y;

        #if mobile
        for (touch in FlxG.touches.list) {
            pointerX = touch.x;
            pointerY = touch.y;
        }
        #end

        var inputJustPressed:Bool = FlxG.mouse.justPressed #if mobile || (FlxG.touches.list.length > 0 && FlxG.touches.list[0].justPressed) #end;
        var inputPressed:Bool = FlxG.mouse.pressed #if mobile || (FlxG.touches.list.length > 0 && FlxG.touches.list[0].pressed) #end;
        var inputJustReleased:Bool = FlxG.mouse.justReleased #if mobile || (FlxG.touches.list.length > 0 && FlxG.touches.list[0].justReleased) #end;

        if (inputJustPressed)
        {
            if (!UI_box.overlapsPoint(new FlxPoint(pointerX, pointerY)))
            {
                for (strum in strumSprites.members)
                {
                    if (strum.overlapsPoint(new FlxPoint(pointerX, pointerY)))
                    {
                        selectedStrum = strum.ID;
                        isDragging = true;
                        
                        dragOffset.x = pointerX - strum.x;
                        dragOffset.y = pointerY - strum.y;
                        
                        strumAlphaStepper.value = strumAlphas[selectedStrum];
                        strumAngleStepper.value = strumAngles[selectedStrum];
                        strumScaleStepper.value = strumScales[selectedStrum];
                        break;
                    }
                }
            }
        }

        if (inputPressed && isDragging && selectedStrum != -1)
        {
            var currentStrumSprite = strumSprites.members[selectedStrum];
            
            var nextX:Float = pointerX - dragOffset.x;
            var nextY:Float = pointerY - dragOffset.y;
            var deltaX:Float = nextX - currentStrumSprite.x;
            var deltaY:Float = nextY - currentStrumSprite.y;

            var affected = getAffectedStrums(selectedStrum);
            for (id in affected)
            {
                strumSprites.members[id].x += deltaX;
                strumSprites.members[id].y += deltaY;
            }
        }

        if (inputJustReleased)
        {
            isDragging = false;
        }

        // CORREGIDO: controls.UI_BACK es la forma correcta y nativa en Psych Engine 1.0+
        if (controls.UI_BACK)
        {
            FlxG.mouse.visible = false;
            MusicBeatState.switchState(new states.editors.MasterEditorMenu());
        }
    }

    function exportModchartLua()
    {
        var fileName:String = StringTools.trim(modchartNameInput.text);
        if (fileName == "") fileName = "custom_modchart";

        var luaContent:String = "-- Script Modchart generado nativamente mediante el Editor Visual Táctil\n";
        luaContent += "-- Desarrollado para Psych Engine 1.0.4\n\n";
        luaContent += "function onCreatePost()\n";
        luaContent += "    -- Modificación de posiciones base, rotaciones y opacidades de flechas\n";

        for (i in 0...8)
        {
            var spr = strumSprites.members[i];
            var groupStr:String = (i < 4) ? "opponentStrums" : "playerStrums";
            var memberID:Int = (i < 4) ? i : (i - 4);

            luaContent += "\n    -- Flecha ID: " + i + " (" + strumsData[i] + ")\n";
            luaContent += "    setPropertyFromGroup('" + groupStr + "', " + memberID + ", 'x', " + FlxMath.roundDecimal(spr.x, 2) + ")\n";
            luaContent += "    setPropertyFromGroup('" + groupStr + "', " + memberID + ", 'y', " + FlxMath.roundDecimal(spr.y, 2) + ")\n";
            
            if (strumAngles[i] != 0)
                luaContent += "    setPropertyFromGroup('" + groupStr + "', " + memberID + ", 'angle', " + strumAngles[i] + ")\n";
            
            if (strumAlphas[i] != 1)
                luaContent += "    setPropertyFromGroup('" + groupStr + "', " + memberID + ", 'alpha', " + strumAlphas[i] + ")\n";
            
            if (strumScales[i] != 0.7) {
                var calculatedScale:Float = strumScales[i] / 0.7; 
                luaContent += "    setPropertyFromGroup('" + groupStr + "', " + memberID + ", 'scale.x', " + FlxMath.roundDecimal(calculatedScale, 2) + ")\n";
                luaContent += "    setPropertyFromGroup('" + groupStr + "', " + memberID + ", 'scale.y', " + FlxMath.roundDecimal(calculatedScale, 2) + ")\n";
            }
        }

        luaContent += "end\n";

        try {
            var exportFolder:String = Paths.mods('data/export/');
            if (!FileSystem.exists(exportFolder)) {
                FileSystem.createDirectory(exportFolder);
            }
            
            var fullPath:String = exportFolder + fileName + ".lua";
            File.saveContent(fullPath, luaContent);
            
            Application.current.window.alert("El archivo se exportó correctamente en:\n" + fullPath, "¡Éxito al Guardar!");
        } catch(e:Dynamic) {
            Application.current.window.alert("Error interno al escribir el archivo: " + e, "Error de Guardado");
        }
    }
}
