package states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIInputText;

// OJO: Si tu port de Android te tira error de "Type not found" en estas 3 líneas, 
// bórrales el "backend." y déjalos solo como "import Paths;" etc. Depende de tu base.
import backend.Paths;
import backend.Mods;
import backend.ClientPrefs;

typedef ModchartAction = {
    var x:Float;
    var y:Float;
    var angle:Float;
    var alpha:Float;
    var duration:Float;
    var ease:String;
}

class ModchartEditorState extends MusicBeatState
{
    var uiBox:FlxSprite;
    var currentTab:String = "Valores";
    
    var testStrums:FlxTypedGroup<FlxSprite>;
    var selectedStrums:Array<Int> = [];
    var selectionMode:String = "ALL";

    var strumActions:Array<Array<ModchartAction>> = [];
    var currentActionIndex:Int = 0;
    
    var isDownscroll:Bool = false;
    var timeElapsed:Float = 0;

    var draggingStrum:FlxSprite = null;
    var dragOffsetX:Float = 0;
    var dragOffsetY:Float = 0;

    var valoresUI:FlxTypedGroup<FlxSprite>;
    var inputX:FlxUIInputText;
    var inputY:FlxUIInputText;

    override function create()
    {
        #if mobile
        FlxG.mouse.visible = true;
        #end

        isDownscroll = ClientPrefs.data.downScroll;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color = 0xFF1A1A2E;
        bg.scrollFactor.set();
        add(bg);

        for (i in 0...8) {
            strumActions.push([{x: 0, y: 0, angle: 0, alpha: 1, duration: 0, ease: "linear"}]);
        }

        testStrums = new FlxTypedGroup<FlxSprite>();
        add(testStrums);
        
        var arrowDirs:Array<String> = ['left', 'down', 'up', 'right'];
        for (i in 0...8) {
            var isPlayer:Bool = (i >= 4);
            var targetX:Float = isPlayer ? 732 + ((i - 4) * 112) : 92 + (i * 112);
            var targetY:Float = isDownscroll ? FlxG.height - 150 : 50; 

            var strum:FlxSprite = new FlxSprite(targetX, targetY);
            strum.frames = Paths.getSparrowAtlas('NOTE_assets');
            strum.animation.addByPrefix('static', 'arrow' + arrowDirs[i % 4].toUpperCase());
            strum.animation.play('static');
            strum.setGraphicSize(Std.int(strum.width * 0.7));
            strum.updateHitbox();
            strum.antialiasing = ClientPrefs.data.antialiasing;
            strum.ID = i;
            testStrums.add(strum);
        }

        buildUI();
        super.create();
    }

    function buildUI() {
        uiBox = new FlxSprite(10, 10).makeGraphic(450, 600, FlxColor.BLACK);
        uiBox.alpha = 0.85;
        add(uiBox);

        var tabs = ["Archivo", "Valores", "Prueba"];
        for (i in 0...tabs.length) {
            var tabBtn = new FlxButton(uiBox.x + 20 + (i * 120), uiBox.y + 10, tabs[i], function() {
                currentTab = tabs[i];
                updateUIPanel();
            });
            tabBtn.resize(110, 40);
            add(tabBtn);
        }

        valoresUI = new FlxTypedGroup<FlxSprite>();
        add(valoresUI);

        var selAllBtn = new FlxButton(uiBox.x + 20, uiBox.y + 70, "Select ALL", function() { changeSelection("ALL"); });
        var selDadBtn = new FlxButton(uiBox.x + 130, uiBox.y + 70, "Select DAD", function() { changeSelection("DAD"); });
        var selBfBtn = new FlxButton(uiBox.x + 240, uiBox.y + 70, "Select BF", function() { changeSelection("BF"); });
        selAllBtn.resize(100, 40); selDadBtn.resize(100, 40); selBfBtn.resize(100, 40);
        
        var resetBtn = new FlxButton(uiBox.x + 350, uiBox.y + 70, "RESET", function() {
            for (id in selectedStrums) {
                var act = strumActions[id][currentActionIndex];
                act.x = 0;
                act.y = 0;
                act.angle = 0;
                act.alpha = 1;
            }
            updateInputTexts();
        });
        resetBtn.resize(80, 40);
        resetBtn.color = FlxColor.RED;
        resetBtn.label.color = FlxColor.WHITE;

        var labelX = new FlxText(uiBox.x + 20, uiBox.y + 130, 0, "Posición X:", 16);
        inputX = new FlxUIInputText(uiBox.x + 20, uiBox.y + 155, 120, "0", 16);
        
        var labelY = new FlxText(uiBox.x + 160, uiBox.y + 130, 0, "Posición Y:", 16);
        inputY = new FlxUIInputText(uiBox.x + 160, uiBox.y + 155, 120, "0", 16);

        var applyBtn = new FlxButton(uiBox.x + 300, uiBox.y + 150, "APLICAR", function() {
            var valX:Float = Std.parseFloat(inputX.text);
            var valY:Float = Std.parseFloat(inputY.text);
            if (Math.isNaN(valX)) valX = 0;
            if (Math.isNaN(valY)) valY = 0;

            for (id in selectedStrums) {
                var act = strumActions[id][currentActionIndex];
                act.x = valX;
                act.y = valY;
            }
        });
        applyBtn.resize(130, 35);
        applyBtn.color = FlxColor.BLUE;
        applyBtn.label.color = FlxColor.WHITE;

        valoresUI.add(selAllBtn);
        valoresUI.add(selDadBtn);
        valoresUI.add(selBfBtn);
        valoresUI.add(resetBtn);
        valoresUI.add(labelX);
        valoresUI.add(inputX);
        valoresUI.add(labelY);
        valoresUI.add(inputY);
        valoresUI.add(applyBtn);

        var exportBtn = new FlxButton(uiBox.x + 20, uiBox.y + 530, "EXPORTAR LUA", function() { exportModchart(); });
        exportBtn.resize(410, 50);
        exportBtn.color = FlxColor.LIME;
        add(exportBtn);

        var closeButton = new FlxButton(FlxG.width - 60, 10, "X", function() { MusicBeatState.switchState(new states.editors.MasterEditorMenu()); });
        closeButton.makeGraphic(50, 50, FlxColor.RED);
        add(closeButton);

        changeSelection("ALL");
        updateUIPanel();
    }

    function changeSelection(mode:String) {
        selectionMode = mode;
        selectedStrums = [];
        for (i in 0...8) {
            testStrums.members[i].color = FlxColor.WHITE;
            if (mode == "ALL") selectedStrums.push(i);
            else if (mode == "DAD" && i < 4) selectedStrums.push(i);
            else if (mode == "BF" && i >= 4) selectedStrums.push(i);
        }
        for (id in selectedStrums) {
            testStrums.members[id].color = FlxColor.CYAN;
        }
        updateInputTexts();
    }

    function updateUIPanel() {
        valoresUI.visible = (currentTab == "Valores");
        valoresUI.active = (currentTab == "Valores");
    }

    function updateInputTexts() {
        if (selectedStrums.length > 0) {
            var firstSelected = selectedStrums[0];
            var act = strumActions[firstSelected][currentActionIndex];
            inputX.text = Std.string(Math.round(act.x));
            inputY.text = Std.string(Math.round(act.y));
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        timeElapsed += elapsed;

        if (inputX.hasFocus || inputY.hasFocus) {
            FlxG.sound.muteKeys = [];
            FlxG.sound.volumeDownKeys = [];
            FlxG.sound.volumeUpKeys = [];
        }

        if (FlxG.mouse.justPressed && !inputX.hasFocus && !inputY.hasFocus) {
            for (i in 0...8) {
                var strum = testStrums.members[i];
                if (FlxG.mouse.overlaps(strum)) {
                    draggingStrum = strum;
                    dragOffsetX = strum.x - FlxG.mouse.x;
                    dragOffsetY = strum.y - FlxG.mouse.y;

                    selectionMode = "INDIVIDUAL";
                    selectedStrums = [strum.ID];
                    for (s in testStrums.members) s.color = FlxColor.WHITE;
                    strum.color = FlxColor.CYAN;
                    
                    updateInputTexts();
                    break;
                }
            }
        }

        if (FlxG.mouse.pressed && draggingStrum != null) {
            var i = draggingStrum.ID;
            var action = strumActions[i][currentActionIndex];
            
            var isPlayer:Bool = (i >= 4);
            var baseDefaultX:Float = isPlayer ? 732 + ((i - 4) * 112) : 92 + (i * 112);
            var baseDefaultY:Float = isDownscroll ? FlxG.height - 150 : 50;

            var newVisualX = FlxG.mouse.x + dragOffsetX;
            var newVisualY = FlxG.mouse.y + dragOffsetY;

            action.x = newVisualX - baseDefaultX;
            
            if (isDownscroll) {
                action.y = baseDefaultY - newVisualY;
            } else {
                action.y = newVisualY - baseDefaultY;
            }

            if (!inputX.hasFocus && !inputY.hasFocus) {
                inputX.text = Std.string(Math.round(action.x));
                inputY.text = Std.string(Math.round(action.y));
            }
        }

        if (FlxG.mouse.justReleased) {
            draggingStrum = null;
        }

        for (i in 0...8) {
            var strum = testStrums.members[i];
            var action = strumActions[i][currentActionIndex]; 
            
            var isPlayer:Bool = (i >= 4);
            var baseDefaultX:Float = isPlayer ? 732 + ((i - 4) * 112) : 92 + (i * 112);
            var baseDefaultY:Float = isDownscroll ? FlxG.height - 150 : 50;

            if (strum != null) {
                strum.x = baseDefaultX + action.x;
                strum.y = isDownscroll ? (baseDefaultY - action.y) : (baseDefaultY + action.y);
                strum.alpha = action.alpha;
                strum.angle = action.angle;
            }
        }
    }

    function exportModchart() {
        var luaCode:String = "-- LUA Modchart Generado desde Psych Engine Android\n";
        luaCode += "local isDownscroll = false\n\n";
        luaCode += "function onCreatePost()\n";
        luaCode += "    isDownscroll = downscroll\n";
        
        for (i in 0...8) {
            var action = strumActions[i][currentActionIndex];
            var group:String = (i >= 4) ? "playerStrums" : "opponentStrums";
            var id:Int = (i >= 4) ? (i - 4) : i;

            if (action.x != 0 || action.y != 0) {
                luaCode += "    noteTweenX('modX" + i + "', " + id + ", default" + (i>=4?"Player":"Opponent") + "StrumX" + id + " + " + action.x + ", " + action.duration + ", '" + action.ease + "')\n";
                luaCode += "    local finalY" + i + " = isDownscroll and (default" + (i>=4?"Player":"Opponent") + "StrumY" + id + " - " + action.y + ") or (default" + (i>=4?"Player":"Opponent") + "StrumY" + id + " + " + action.y + ")\n";
                luaCode += "    noteTweenY('modY" + i + "', " + id + ", finalY" + i + ", " + action.duration + ", '" + action.ease + "')\n";
            }
        }
        luaCode += "end\n";

        #if sys
        try {
            var rootPath:String = "";
            #if android
            rootPath = lime.system.System.applicationStorageDirectory;
            #end

            var currentModDir:String = "scripts/";
            if (Mods.currentModDirectory != null && Mods.currentModDirectory.length > 0) {
                currentModDir = Mods.currentModDirectory + "/scripts/";
            }

            var finalPath:String = rootPath + "mods/" + currentModDir;

            // LLAMADA ABSOLUTA AL SISTEMA (Evita el "Unknown identifier")
            if (!sys.FileSystem.exists(finalPath)) {
                sys.FileSystem.createDirectory(finalPath);
            }
            
            sys.io.File.saveContent(finalPath + "modchart_exportado.lua", luaCode);
            FlxG.sound.play(Paths.sound('confirmMenu'));
            
        } catch(e:Dynamic) {
            trace("ERROR AL GUARDAR: " + e);
        }
        #end
    }
}

