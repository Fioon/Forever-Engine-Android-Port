package gameFolder.gameObjects;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import gameFolder.gameObjects.background.*;
import gameFolder.meta.state.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.Song.SwagSong;

using StringTools;
/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	var halloweenBG:FlxSprite;
	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	public var limo:FlxSprite;
	public var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	public var backgroundarray:Array<FlxSprite>=[];

	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var defaultCamZoom:Float = 1.05;

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		//

		switch (curStage)
		{
			default:
				curStage = 'madagascar';
				defaultCamZoom = 0.80;
						
						var skyBG:FlxSprite = new FlxSprite(-400, -100).loadGraphic(Paths.image('backgrounds/madagascar/limoSunset'));
						skyBG.scrollFactor.set(0.1, 0.1);						
                        add(skyBG);

						var tree:FlxSprite = new FlxSprite(-1000, -100).loadGraphic(Paths.image('backgrounds/madagascar/Tree'));
						FlxTween.tween(tree, {x: 5000}, 0.5, {type: FlxTweenType.LOOPING, ease: FlxEase.smoothStepInOut, loopDelay: 1});
						tree.scrollFactor.set(0.2, 0.2);						
                        add(tree);

					    var road = new FlxSprite(-1000, 650);
						road.scale.set(2, 1);
						road.scrollFactor.set(0.9, 0.9);
						road.frames = Paths.getSparrowAtlas('backgrounds/madagascar/Road');
						road.animation.addByPrefix('Road', "Road", 24);
						road.animation.play('Road');
						add(road);

						var jeep4 = new FlxSprite(-1400, 550);
						FlxTween.tween(jeep4, {x: -1200}, 4, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
						jeep4.frames = Paths.getSparrowAtlas('backgrounds/madagascar/Shitty_Jeep');
						jeep4.animation.addByPrefix('Shitty Jeep', "Shitty Jeep", 24);
						jeep4.animation.play('Shitty Jeep');
						jeep4.antialiasing = true;
					    add(jeep4);

                        var dd:FlxSprite = new FlxSprite(550, 700).loadGraphic(Paths.image('backgrounds/madagascar/Demon_Driver'));					
						FlxTween.tween(dd, {x: 250}, 3, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
						dd.antialiasing = true;
                        add(dd);

					    var jeep3 = new FlxSprite(350, 750);
						FlxTween.tween(jeep3, {x: 50}, 3, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
						jeep3.scale.set(1.5, 1.5);
						jeep3.frames = Paths.getSparrowAtlas('backgrounds/madagascar/Shitty_Jeep');
						jeep3.animation.addByPrefix('Shitty Jeep', "Shitty Jeep", 24);
						jeep3.animation.play('Shitty Jeep');
						jeep3.antialiasing = true;
						add(jeep3);

						var kow:FlxSprite = new FlxSprite(-775, 650).loadGraphic(Paths.image('backgrounds/madagascar/Kowalski'));					
						kow.antialiasing = true;
						FlxTween.tween(kow, {x: -575}, 4, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
                        add(kow);

						var pr:FlxSprite = new FlxSprite(-850, 650).loadGraphic(Paths.image('backgrounds/madagascar/Private'));					
						pr.antialiasing = true;
						FlxTween.tween(pr, {x: -650}, 4, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
                        add(pr);

						var rico:FlxSprite = new FlxSprite(-1100, 650).loadGraphic(Paths.image('backgrounds/madagascar/Rico'));					
						rico.antialiasing = true;
						FlxTween.tween(rico, {x: -900}, 4, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
						add(rico);

						var skyBG2:FlxSprite = new FlxSprite(-400, -100).loadGraphic(Paths.image('backgrounds/madagascarS/limoSunset'));
						skyBG2.scrollFactor.set(0.1, 0.1);						
						skyBG2.antialiasing = true;
						skyBG2.visible = false;
						add(skyBG2);

						var tree2:FlxSprite = new FlxSprite(-1000, -100).loadGraphic(Paths.image('backgrounds/madagascarS/Tree'));
						FlxTween.tween(tree2, {x: 5000}, 0.5, {type: FlxTweenType.LOOPING, ease: FlxEase.smoothStepInOut, loopDelay: 1});
						tree2.scrollFactor.set(0.2, 0.2);	
						tree2.visible = false;
                        add(tree2);

					    var road2 = new FlxSprite(-1000, 650);
						road2.scale.set(2, 1);
						road2.scrollFactor.set(0.9, 0.9);
						road2.frames = Paths.getSparrowAtlas('backgrounds/madagascarS/Road');
						road2.animation.addByPrefix('Road', "Road", 24);
						road2.animation.play('Road');
						road2.visible = false;
						add(road2);

						var jeep = new FlxSprite(300, 750);
						FlxTween.tween(jeep, {x: 0}, 3, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
						jeep.scale.set(1.5, 1.5);
						jeep.frames = Paths.getSparrowAtlas('backgrounds/madagascarS/Better_Jeep_BF');
						jeep.animation.addByPrefix('Truck Low Quality', "Truck Low Quality", 24);
						jeep.animation.play('Truck Low Quality');
						jeep.antialiasing = true;
						jeep.visible = false;
						add(jeep);
						
					    var jeep2 = new FlxSprite(-1400, 550);
						FlxTween.tween(jeep2, {x: -1200}, 4, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
						jeep2.frames = Paths.getSparrowAtlas('backgrounds/madagascarS/Better_Jeep');
						jeep2.animation.addByPrefix('Truck', "Truck", 24);
						jeep2.animation.play('Truck');
						jeep2.antialiasing = true;
						jeep2.visible = false;
						add(jeep2);

						backgroundarray = [tree, tree2, road, road2, skyBG, skyBG2, jeep, jeep2, jeep3, dd, jeep4, kow, rico, pr];
						
		}
	}
	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'highway':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'prejudice':
				gfVersion = 'gf-car';
		}

		return gfVersion;
	}

	// get the dad's position
	public function dadPosition(curStage, dad:Character, gf:Character, camPos:FlxPoint, songPlayer2):Void
	{
		switch (songPlayer2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			/*
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
			}*/

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':
				dad.x += 50;
				dad.y += 200;
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character, gf:Character):Void
	{
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'highway':
				boyfriend.y -= 220;
				boyfriend.x += 260;

			// resetFastCar();
			// add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				// var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				// add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'madagascar' | 'madagascarS':
				dad.y +=200;
				dad.x -= 700;
				FlxTween.tween(dad, {x: dad.x + 200}, 4, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
				boyfriend.y -=150;
				FlxTween.tween(boyfriend, {x: boyfriend.x - 300}, 3, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});
				gf.y +=225;
				gf.x +=800;
				FlxTween.tween(gf, {x: gf.x - 300}, 3, { type: FlxTween.PINGPONG, ease: FlxEase.sineInOut, loopDelay: 0});

				var evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
				var evilTrail2 = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail2);

		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	public function stageUpdate(curBeat:Int, curStep:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch (PlayState.curStage)
		{
			// yoshubs hacvking tsusuranrarn s computre
			case 'madagascar':
				if (curStep == 640 || curStep == 1152 || curStep == 1920)
					for (i in backgroundarray)
						i.visible = !i.visible;
		}
		//
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos(gf);
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}
	}

	// PHILLY STUFFS!
	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	function updateTrainPos(gf:Character):Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset(gf);
		}
	}

	function trainReset(gf:Character):Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}
}
