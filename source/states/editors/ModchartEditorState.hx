package states.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.ui.FlxUIInputText;
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
        add(bg);

        for (i in 0...8) strumActions.push([{x: 0, y: 0, angle: 0, alpha: 1, duration: 0, ease: "linear"}]);

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

        valoresUI = new FlxTypedGroup<FlxSprite>();
        add(valoresUI);

        var selAllBtn = new FlxButton(uiBox.x + 20, uiBox.y + 70, "Select ALL", function() changeSelection("ALL"));
        var resetBtn = new FlxButton(uiBox.x + 350, uiBox.y + 70, "RESET", function() {
            for (id in selectedStrums) {
                strumActions[id][currentActionIndex].x = 0;
                strumActions[id][currentActionIndex].y = 0;
            }
            updateInputTexts();
        });
        resetBtn.color = FlxColor.RED;

        inputX = new FlxUIInputText(uiBox.x + 20, uiBox.y + 155, 120, "0", 16);
        inputY = new FlxUIInputText(uiBox.x + 160, uiBox.y + 155, 120, "0", 16);

        var applyBtn = new FlxButton(uiBox.x + 300, uiBox.y + 150, "APLICAR", function() {
            for (id in selectedStrums) {
                strumActions[id][currentActionIndex].x = Std.parseFloat(inputX.text);
                strumActions[id][currentActionIndex].y = Std.parseFloat(inputY.text);
            }
        });

        valoresUI.add(selAllBtn);
        valoresUI.add(resetBtn);
        valoresUI.add(inputX);
        valoresUI.add(inputY);
        valoresUI.add(applyBtn);

        var exportBtn = new FlxButton(uiBox.x + 20, uiBox.y + 530, "EXPORTAR LUA", exportModchart);
        add(exportBtn);
        changeSelection("ALL");
    }

    function changeSelection(mode:String) {
        selectedStrums = [];
        for (i in 0...8) {
            testStrums.members[i].color = FlxColor.WHITE;
            if (mode == "ALL") selectedStrums.push(i);
        }
        updateInputTexts();
    }

    function updateInputTexts() {
        if (selectedStrums.length > 0) {
            inputX.text = Std.string(strumActions[selectedStrums[0]][currentActionIndex].x);
            inputY.text = Std.string(strumActions[selectedStrums[0]][currentActionIndex].y);
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (FlxG.mouse.justPressed && !inputX.hasFocus && !inputY.hasFocus) {
            for (i in 0...8) {
                if (FlxG.mouse.overlaps(testStrums.members[i])) {
                    draggingStrum = testStrums.members[i];
                    dragOffsetX = draggingStrum.x - FlxG.mouse.x;
                    dragOffsetY = draggingStrum.y - FlxG.mouse.y;
                    break;
                }
            }
        }

        if (FlxG.mouse.pressed && draggingStrum != null) {
            var i = draggingStrum.ID;
            var act = strumActions[i][currentActionIndex];
            var baseX = (i >= 4) ? 732 + ((i - 4) * 112) : 92 + (i * 112);
            var baseY = isDownscroll ? FlxG.height - 150 : 50;
            act.x = (FlxG.mouse.x + dragOffsetX) - baseX;
            act.y = isDownscroll ? baseY - (FlxG.mouse.y + dragOffsetY) : (FlxG.mouse.y + dragOffsetY) - baseY;
            updateInputTexts();
        }

        if (FlxG.mouse.justReleased) draggingStrum = null;

        for (i in 0...8) {
            var act = strumActions[i][currentActionIndex];
            var baseX = (i >= 4) ? 732 + ((i - 4) * 112) : 92 + (i * 112);
            var baseY = isDownscroll ? FlxG.height - 150 : 50;
            testStrums.members[i].x = baseX + act.x;
            testStrums.members[i].y = isDownscroll ? baseY - act.y : baseY + act.y;
        }
    }

    function exportModchart() {
        #if sys
        var path = lime.system.System.applicationStorageDirectory + "mods/" + (Mods.currentModDirectory != null ? Mods.currentModDirectory : "") + "/scripts/";
        if (!sys.FileSystem.exists(path)) sys.FileSystem.createDirectory(path);
        sys.io.File.saveContent(path + "modchart_exportado.lua", "-- Modchart generado");
        #end
    }
}
