package gameFolder.meta.state;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gameFolder.gameObjects.*;
import gameFolder.gameObjects.userInterface.*;
import gameFolder.meta.*;
import gameFolder.meta.MusicBeat.MusicBeatState;
import gameFolder.meta.data.*;
import gameFolder.meta.data.Song.SwagSong;
import gameFolder.meta.state.charting.*;
import gameFolder.meta.state.menus.*;
import gameFolder.meta.subState.*;
import gameFolder.gameObjects.Stage.*;
import openfl.utils.Assets;
import lime.app.Application;


using StringTools;

class PlayState extends MusicBeatState
{
	public static var startTimer:FlxTimer;

	public static var curStage:String = 'madagascar';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 2;

	public static var songMusic:FlxSound;
	public static var vocals:FlxSound;

	public static var campaignScore:Int = 0;

	public static var dadOpponent:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var boyfriendAutoplay:Bool = false;

	private var dadAutoplay:Bool = true; // this is for testing purposes

	private var assetModifier:String = 'base';

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
	private var ratingArray:Array<String> = [];
	private var allSicks:Bool = true;

	// control arrays I'll use later
	var holdControls:Array<Bool> = [];
	var pressControls:Array<Bool> = [];
	var releaseControls:Array<Bool> = []; // haha garcello!

	// get it cus release
	// I'm funny just trust me
	private var curSection:Int = 0;
	private var camFollow:FlxObject;

	//
	private static var prevCamFollow:FlxObject;

	// strums
	private var strumLine:FlxTypedGroup<FlxSprite>;

	public static var strumLineNotes:FlxTypedGroup<UIStaticArrow>;

	private var boyfriendStrums:FlxTypedGroup<UIStaticArrow>;
	private var dadStrums:FlxTypedGroup<UIStaticArrow>;

	private var curSong:String = "";
	private var splashNotes:FlxTypedGroup<NoteSplash>;

	private var gfSpeed:Int = 1;

	public static var health:Float = 1; // mario
	public static var combo:Int = 0;
	public static var misses:Int = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;

	private var camDisplaceX:Float = 0;
	private var camDisplaceY:Float = 0; // using this cus tsu and clockwerk asked

	public static var defaultCamZoom:Float = 1.05;

	public static var forceZoom:Array<Float>;

	public static var songScore:Int = 0;

	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;

	private var stageBuild:Stage;
	private var uiHUD:ClassHUD;

	public static var daPixelZoom:Float = 6;
	public static var determinedChartType:String = "";

	private var ratingsGroup:FlxTypedGroup<FlxSprite>;
	private var timingsGroup:FlxTypedGroup<FlxSprite>;
	private var scoreGroup:FlxTypedGroup<FlxSprite>;

	// at the beginning of the playstate
	override public function create()
	{
		// reset any values and variables that are static
		songScore = 0;
		combo = 0;
		health = 1;
		misses = 0;

		defaultCamZoom = 1.05;
		forceZoom = [0, 0, 0, 0];

		Timings.callAccuracy();

		// initialise the groups!
		ratingsGroup = new FlxTypedGroup<FlxSprite>();
		timingsGroup = new FlxTypedGroup<FlxSprite>();
		scoreGroup = new FlxTypedGroup<FlxSprite>();

		// stop any existing music tracks playing
		resetMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		// default song
		if (SONG == null)
			SONG = Song.loadFromJson('test', 'test');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		// will change this to make it better later!
		// you'll be able to add your own uis
		if (Init.gameSettings.get("use Forever Engine UI"))
			assetModifier = 'forever';

		/// here we determine the chart type!
		// determine the chart type here
		determinedChartType = "FNF";

		//

		// set up a class for the stage type in here afterwards
		curStage = "madagascar";
		// call the song's stage if it exists
		if (SONG.stage != null)
			curStage = SONG.stage;

		stageBuild = new Stage(curStage);
		add(stageBuild);

		/*
			Everything related to the stages aside from things done after are set in the stage class!
			this means that the girlfriend's type, boyfriend's position, dad's position, are all there

			It serves to clear clutter and can easily be destroyed later. The problem is,
			I don't actually know if this is optimised, I just kinda roll with things and hope
			they work. I'm not actually really experienced compared to a lot of other developers in the scene, 
			so I don't really know what I'm doing, I'm just hoping I can make a better and more optimised 
			engine for both myself and other modders to use!
		 */

		// set up characters here too
		gf = new Character(400, 130, stageBuild.returnGFtype(curStage));
		gf.scrollFactor.set(0.95, 0.95);

		dadOpponent = new Character(100, 100, SONG.player2);
		boyfriend = new Boyfriend(770, 450, SONG.player1);

		var camPos:FlxPoint = new FlxPoint(gf.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

		// set the dad's position (check the stage class to edit that!)
		// reminder that this probably isn't the best way to do this but hey it works I guess and is cleaner
		stageBuild.dadPosition(curStage, dadOpponent, gf, camPos, SONG.player2);

		// I don't like the way I'm doing this, but basically hardcode stages to charts if the chart type is the base fnf one
		// (forever engine charts will have non hardcoded stages)

		if ((curStage.startsWith("school")) && ((determinedChartType == "FNF")))
			assetModifier += 'pixel';

		// isPixel = true;

		// reposition characters
		stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);

		// add characters
		add(gf);

		add(dadOpponent);
		add(boyfriend);

		// force them to dance
		dadOpponent.dance();
		gf.dance();
		boyfriend.dance();

		// set song position before beginning
		Conductor.songPosition = -5000;

		// create strums and ui elements
		strumLine = new FlxTypedGroup<FlxSprite>();
		var strumLineY:Int = 50;

		if (Init.gameSettings.get('Downscroll')[0])
			strumLineY = FlxG.height - (strumLineY * 3);
		// trace('downscroll works???');

		for (i in 0...8)
		{
			var strumLinePart = new FlxSprite(0, strumLineY).makeGraphic(FlxG.width, 10);
			strumLinePart.scrollFactor.set();

			strumLine.add(strumLinePart);
		}

		// set up the elements for the notes
		strumLineNotes = new FlxTypedGroup<UIStaticArrow>();
		add(strumLineNotes);

		// now splash notes
		splashNotes = new FlxTypedGroup<NoteSplash>();
		add(splashNotes);

		// and now the note strums
		boyfriendStrums = new FlxTypedGroup<UIStaticArrow>();
		dadStrums = new FlxTypedGroup<UIStaticArrow>();

		// generate the song
		generateSong(SONG.song);

		// set the camera position to the center of the stage
		camPos.set(gf.x + (gf.width / 2), gf.y + (gf.height / 2));

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		// check if the camera was following someone previouslyw
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		// set up camera dependencies (so that ui elements correspond to their cameras and such)
		strumLineNotes.cameras = [camHUD];
		splashNotes.cameras = [camHUD];
		notes.cameras = [camHUD];

		// actually set the camera up
		var camLerp = Main.framerateAdjust(0.02);
		FlxG.camera.follow(camFollow, LOCKON, camLerp);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// initialize ui elements
		startingSong = true;
		startedCountdown = true;

		for (i in 0...2)
			generateStaticArrows(i);

		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.cameras = [camHUD];
		//
		#if android
		addAndroidControls();
		#end

		// call the funny intro cutscene depending on the song
		if (isStoryMode)
			songIntroCutscene();
		else
			startCountdown();

		super.create();
	}

	override public function update(elapsed:Float)
	{
		stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dadOpponent);

		super.update(elapsed);

		if (health > 2)
			health = 2;

		// pause the game if the game is allowed to pause and enter is pressed
		if (FlxG.android.justReleased.BACK && startedCountdown && canPause)
		{
			// update drawing stuffs
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// open pause substate
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			#if desktop
			// DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		// make sure you're not cheating lol
		if (!isStoryMode)
		{
			// charting state (more on that later)
			if ((FlxG.keys.justPressed.SEVEN) && (!startingSong))
			{
				resetMusic();
				if (Init.gameSettings.get('Use Forever Chart Editor')[0])
					Main.switchState(new ChartingState());
				else
					Main.switchState(new OriginalChartingState());
			}

			if (FlxG.keys.justPressed.SIX)
				boyfriendAutoplay = !boyfriendAutoplay;
		}

		///*
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;

			// song shit for testing lols
		}

		// boyfriend.playAnim('singLEFT', true);
		// */

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var char = dadOpponent;

				var getCenterX = char.getMidpoint().x + 150;
				var getCenterY = char.getMidpoint().y - 100;
				switch (dadOpponent.curCharacter)
				{
					case 'mom':
						getCenterY = char.getMidpoint().y;
					case 'senpai':
						getCenterY = char.getMidpoint().y - 430;
						getCenterX = char.getMidpoint().x - 100;
					case 'senpai-angry':
						getCenterY = char.getMidpoint().y - 430;
						getCenterX = char.getMidpoint().x - 100;
				}

				camFollow.setPosition(getCenterX + (camDisplaceX * 8), getCenterY + (camDisplaceY * 8));

				if (char.curCharacter == 'mom')
					vocals.volume = 1;

				/*
					if (SONG.song.toLowerCase() == 'tutorial')
					{
						FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
					}
				 */
			}
			else
			{
				var char = boyfriend;

				var getCenterX = char.getMidpoint().x - 100;
				var getCenterY = char.getMidpoint().y - 100;
				switch (curStage)
				{
					case 'limo':
						getCenterX = char.getMidpoint().x - 300;
					case 'mall':
						getCenterY = char.getMidpoint().y - 200;
					case 'school':
						getCenterX = char.getMidpoint().x - 200;
						getCenterY = char.getMidpoint().y - 200;
					case 'schoolEvil':
						getCenterX = char.getMidpoint().x - 200;
						getCenterY = char.getMidpoint().y - 200;
				}

				camFollow.setPosition(getCenterX + (camDisplaceX * 8), getCenterY + (camDisplaceY * 8));

				/*
					if (SONG.song.toLowerCase() == 'tutorial')
					{
						FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
					}
				 */
			}
		}

		var easeLerp = 0.95;
		// camera stuffs
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
		camHUD.zoom = FlxMath.lerp(1 + forceZoom[1], camHUD.zoom, easeLerp);

		// not even forcezoom anymore but still
		FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
		camHUD.angle = FlxMath.lerp(0 + forceZoom[3], camHUD.angle, easeLerp);

		if ((strumLineNotes.members.length > 0) && (!startingSong))
		{
			// fuckin uh strumline note stuffs
			for (i in 0...strumLineNotes.members.length)
			{
				strumLineNotes.members[i].x = FlxMath.lerp(strumLineNotes.members[i].xTo, strumLineNotes.members[i].x, easeLerp);
				strumLineNotes.members[i].y = FlxMath.lerp(strumLineNotes.members[i].yTo, strumLineNotes.members[i].y, easeLerp);

				strumLineNotes.members[i].angle = FlxMath.lerp(strumLineNotes.members[i].angleTo, strumLineNotes.members[i].angle, easeLerp);
			}
		}

		if (health <= 0 && startedCountdown)
		{
			// startTimer.active = false;
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			resetMusic();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// discord stuffs should go here
		}

		// spawn in the notes from the array
		if (unspawnNotes[0] != null)
		{
			if ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);

				// thanks sammu I have no idea how this line works lmao
				notes.sort(FlxSort.byY, (!Init.gameSettings.get('Downscroll')[0]) ? FlxSort.DESCENDING : FlxSort.ASCENDING);
			}
		}

		// handle all of the note calls
		noteCalls();
	}

	//----------------------------------------------------------------
	//
	//
	//
	//	this is just a divider, move long.
	//
	//
	//
	//----------------------------------------------------------------

	private function mainControls(daNote:Note, char:Character, charStrum:FlxTypedGroup<UIStaticArrow>, autoplay:Bool, ?otherSide:Int = 0):Void
	{
		// call character type for later I'm so sorry this is painful
		var charCallType:Int = 0;
		if (char == boyfriend)
			charCallType = 1;

		// uh if condition from the original game

		// I have no idea what I have done
		var downscrollMultiplier = 1;
		if (Init.gameSettings.get('Downscroll')[0])
			downscrollMultiplier = -1;

		// im very sorry for this if condition I made it worse lmao
		///*
		if (daNote.isSustainNote
			&& (((daNote.y + daNote.offset.y <= (strumLine.members[Math.floor(daNote.noteData + (otherSide * 4))].y + Note.swagWidth / 2))
				&& !Init.gameSettings.get('Downscroll')[0])
				|| (((daNote.y - (daNote.offset.y * daNote.scale.y) + daNote.height) >= (strumLine.members[Math.floor(daNote.noteData + (otherSide * 4))].y
					+ Note.swagWidth / 2))
					&& Init.gameSettings.get('Downscroll')[0]))
			&& (autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
		{
			var swagRectY = ((strumLine.members[Math.floor(daNote.noteData + (otherSide * 4))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y);
			var swagRect = new FlxRect(0, 0, daNote.width * 2, daNote.height * 2);
			// I feel genuine pain
			// basically these should be flipped based on if it is downscroll or not
			if (Init.gameSettings.get('Downscroll')[0])
			{
				swagRect.height = swagRectY;
				swagRect.y -= swagRect.height - daNote.height;
			}
			else
			{
				swagRect.y = swagRectY;
				swagRect.height -= swagRect.y;
			}

			daNote.clipRect = swagRect;
		}
		// */

		// here I'll set up the autoplay functions
		if (autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition)
			{
				// use a switch thing cus it feels right idk lol
				// make sure the strum is played for the autoplay stuffs
				/*
					charStrum.forEach(function(cStrum:UIStaticArrow)
					{
						strumCallsAuto(cStrum, 0, daNote);
					});
				 */

				// kill the note, then remove it from the array
				var canDisplayRating = false;
				if (charCallType == 1)
				{
					canDisplayRating = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayRating = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double ratings is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}

				goodNoteHit(daNote, char, charStrum, canDisplayRating);
			}
			//
		}

		// unoptimised asf camera control based on strums
		switch (charCallType)
		{
			case 1:
				strumCameraRoll(boyfriendStrums, true);
			default:
				strumCameraRoll(dadStrums, false);
		}
	}

	//----------------------------------------------------------------
	//
	//
	//
	//	strum calls auto
	//
	//
	//
	//----------------------------------------------------------------

	private function strumCallsAuto(cStrum:UIStaticArrow, ?callType:Int = 1, ?daNote:Note):Void
	{
		switch (callType)
		{
			case 1:
				// end the animation if the calltype is 1 and it is done
				if ((cStrum.animation.finished) && (cStrum.canFinishAnimation))
					cStrum.playAnim('static');
			default:
				// check if it is the correct strum
				if (daNote.noteData == cStrum.ID)
				{
					// if (cStrum.animation.curAnim.name != 'confirm')
					cStrum.playAnim('confirm'); // play the correct strum's confirmation animation (haha rhymes)

					// stuff for sustain notes
					if ((daNote.isSustainNote) && (!daNote.animation.curAnim.name.endsWith('holdend')))
						cStrum.canFinishAnimation = false; // basically, make it so the animation can't be finished if there's a sustain note below
					else
						cStrum.canFinishAnimation = true;
				}
		}
	}

	private function strumCameraRoll(cStrum:FlxTypedGroup<UIStaticArrow>, mustHit:Bool)
	{
		if (!Init.gameSettings.get('No Camera Note Movement')[0])
		{
			var camDisplaceExtend:Float = 1.5;
			var camDisplaceSpeed = 0.0125;
			if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && mustHit)
					|| (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !mustHit))
				{
					if ((cStrum.members[0].animation.curAnim.name == 'confirm') && (camDisplaceX > -camDisplaceExtend))
						camDisplaceX -= camDisplaceSpeed;
					else if ((cStrum.members[3].animation.curAnim.name == 'confirm') && (camDisplaceX < camDisplaceExtend))
						camDisplaceX += camDisplaceSpeed;
					// y values
					if ((cStrum.members[1].animation.curAnim.name == 'confirm') && (camDisplaceY < camDisplaceExtend))
						camDisplaceY += camDisplaceSpeed;
					else if ((cStrum.members[2].animation.curAnim.name == 'confirm') && (camDisplaceY > -camDisplaceExtend))
						camDisplaceY -= camDisplaceSpeed;
				}
			}
		}
		//
	}

	//----------------------------------------------------------------
	//
	//
	//
	//
	//	idk I just need these cus the code is killing me
	//  I wanna see where the lines are for different functions
	//
	//
	//
	//----------------------------------------------------------------
	// call a note array
	public var notesPressedAutoplay:Array<Note> = [];

	private function noteCalls():Void
	{
		// get ready for nested script calls!

		// set up the controls for later usage
		// (control stuffs don't go here they go in noteControls(), I just have them here so I don't call them every. single. time. noteControls() is called)
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var holdControls = [left, down, up, right];
		var pressControls = [leftP, downP, upP, rightP];
		var releaseControls = [leftR, downR, upR, rightR];

		// handle strumline stuffs
		for (i in 0...strumLine.length)
			strumLine.members[i].y = strumLineNotes.members[i].y + 25;

		for (i in 0...splashNotes.length)
		{
			// splash note positions
			splashNotes.members[i].x = strumLineNotes.members[i + 4].x - 48;
			splashNotes.members[i].y = strumLineNotes.members[i + 4].y - 56;
		}

		// reset strums
		for (i in 0...4)
		{
			boyfriendStrums.forEach(function(cStrum:UIStaticArrow)
			{
				if (boyfriendAutoplay)
					strumCallsAuto(cStrum);
			});
			dadStrums.forEach(function(cStrum:UIStaticArrow)
			{
				if (dadAutoplay)
					strumCallsAuto(cStrum);
			});
		}

		// if the song is generated
		if (generatedMusic)
		{
			// nested script #1
			controlPlayer(boyfriend, boyfriendAutoplay, boyfriendStrums, holdControls, pressControls, releaseControls);
			// controlPlayer(dadOpponent, dadAutoplay, dadStrums, holdControls, pressControls, releaseControls, false);

			notesPressedAutoplay = [];
			// call every single note that exists!
			notes.forEachAlive(function(daNote:Note)
			{
				// ya so this might be a lil unoptimised so I'm gonna keep it to a minimum with the calls honestly I'd rather not do them a lot

				// first we wanna orient the note positions.
				// lord forgive me for what I'm about to do but I can't use booleans as integers

				// don't follow this it's hellaaaa stupid code
				var otherSide = 0;
				var otherSustain:Float = 0;
				if (daNote.mustPress)
					otherSide = 1;
				if (daNote.isSustainNote)
					otherSustain = daNote.width;

				// set the notes x and y
				var downscrollMultiplier = 1;
				if (Init.gameSettings.get('Downscroll')[0])
					downscrollMultiplier = -1;

				daNote.y = (strumLine.members[Math.floor(daNote.noteData + (otherSide * 4))].y
					+ (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)))));
				/*
					heres the part where I talk about how shitty my downscroll code is
					mostly because I don't actually understand downscroll and I don't play downscroll so its really more
					of an afterthought, if you feel like improving the code lemme know or make a pr or something I'll gladly accept it

					EDIT: I'm gonna try to revise it but no promises
					ya I give up if you wanna fix it go ahead idc anymore
					UPDATE: I MIGHT HAVE FIXED IT!!!!
				 */

				if (daNote.isSustainNote)
				{
					// note alignments (thanks pixl for pointing out what made old downscroll weird)
					if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
					{
						if (Init.gameSettings.get('Downscroll')[0])
							daNote.y += (daNote.prevNote.height);
						else
							daNote.y -= ((daNote.prevNote.height / 2));
					}
					else
						daNote.y -= ((daNote.height / 2) * downscrollMultiplier);
					if (Init.gameSettings.get('Downscroll')[0])
						daNote.flipY = true;
				}

				daNote.x = strumLineNotes.members[Math.floor(daNote.noteData + (otherSide * 4))].x + 25 + otherSustain;

				// also set note rotation
				if (daNote.isSustainNote == false)
					daNote.angle = strumLineNotes.members[Math.floor(daNote.noteData + (otherSide * 4))].angle;

				// hell breaks loose here, we're using nested scripts!
				// get the note lane and run the corresponding script
				///*
				if (daNote.mustPress)
					mainControls(daNote, boyfriend, boyfriendStrums, boyfriendAutoplay, otherSide);
				else
					mainControls(daNote, dadOpponent, dadStrums, dadAutoplay); // dadOpponent autoplay is true by default and should be true unless neccessary
				// */

				// check where the note is and make sure it is either active or inactive
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				// if the note is off screen (above)
				if (((!Init.gameSettings.get('Downscroll')[0]) && (daNote.y < -daNote.height))
					|| ((Init.gameSettings.get('Downscroll')[0]) && (daNote.y > (FlxG.height + daNote.height))))
				{
					if ((daNote.tooLate || !daNote.wasGoodHit) && (daNote.mustPress))
					{
						healthCall(false);
						vocals.volume = 0;

						// I'll ask pixl if this is wrong and if he says yes I'll remove it
						decreaseCombo();

						// ambiguous name
						Timings.updateAccuracy(0);
					}

					daNote.active = false;
					daNote.visible = false;

					// note damage here I guess
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
			//
		}
	}

	function controlPlayer(character:Character, autoplay:Bool, characterStrums:FlxTypedGroup<UIStaticArrow>, holdControls:Array<Bool>,
			pressControls:Array<Bool>, releaseControls:Array<Bool>, ?mustPress = true)
	{
		if (!autoplay)
		{
			// check if anything is pressed
			if (pressControls.contains(true))
			{
				// check all of the controls
				for (i in 0...pressControls.length)
				{
					// improved this a little bit, maybe its a lil
					var possibleNoteList:Array<Note> = [];
					var pressedNotes:Array<Note> = [];

					notes.forEachAlive(function(daNote:Note)
					{
						if ((daNote.noteData == i) && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
						{
							possibleNoteList.push(daNote);
							possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
						}
					});

					// if there is a list of notes that exists for that control
					if (possibleNoteList.length > 0)
					{
						var eligable = true;
						// this may be impractical, but I want overlayed notes to be played, just not count towards score or combo
						// this is so that they run code and stuff
						var firstNote = true;
						// loop through the possible notes
						for (coolNote in possibleNoteList)
						{
							// and if a note is being pressed
							if (pressControls[coolNote.noteData])
							{
								for (noteDouble in pressedNotes)
								{
									if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
										firstNote = false;
									else
										eligable = false;
								}

								if (eligable)
								{
									goodNoteHit(coolNote, character, characterStrums, firstNote); // then hit the note
									pressedNotes.push(coolNote);
								}
							}
							// end of this little check
						}
						//
					}
					else
						missNoteCheck(i, pressControls, character); // else just call bad notes
					//
				}

				//
			}

			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				notes.forEachAlive(function(coolNote:Note)
				{
					if (coolNote.canBeHit && coolNote.mustPress && coolNote.isSustainNote && holdControls[coolNote.noteData])
						goodNoteHit(coolNote, character, characterStrums);
				});
			}

			// control camera movements
			// strumCameraRoll(characterStrums, true);

			characterStrums.forEach(function(strum:UIStaticArrow)
			{
				if ((pressControls[strum.ID]) && (strum.animation.curAnim.name != 'confirm'))
					strum.playAnim('pressed');
				if (releaseControls[strum.ID])
					strum.playAnim('static');
				//
			});
		}

		// reset bf's animation
		if (character.holdTimer > Conductor.stepCrochet * (4 / 1000) && (!holdControls.contains(true) || autoplay))
		{
			if (character.animation.curAnim.name.startsWith('sing') && !character.animation.curAnim.name.endsWith('miss'))
				character.dance();
		}
	}

	private var ratingTiming:String = "";

	function popUpScore(daRatings:Map<String, Array<Dynamic>>, baseRating:String, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick")
		{
			// create the note splash if you hit a sick
			createSplash(coolNote);
		}
		else
		{
			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;
		}

		displayRating(baseRating);
		Timings.updateAccuracy(daRatings.get(baseRating)[3]);
		score = Std.int(daRatings.get(baseRating)[1]);

		songScore += score;

		popUpCombo();
	}

	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo()
	{
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('num' + stringArray[scoreInt], assetModifier, 'UI', negative, createdColor, scoreInt, scoreGroup);
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.kill();
				},
				startDelay: Conductor.crochet * 0.002
			});
		}
	}

	//
	//
	//

	function decreaseCombo()
	{
		// painful if statement
		if (((combo > 5) || (combo < 0)) && (gf.animOffsets.exists('sad')))
			gf.playAnim('sad');

		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		songScore -= 10;
		misses++;

		// display negative combo
		popUpCombo();
		displayRating("miss");
	}

	function increaseCombo()
	{
		if (combo < 0)
			combo = 0;
		combo += 1;
	}

	//
	//
	//

	public function createSplash(coolNote:Note)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom);
	}

	public function displayRating(daRating:String)
	{
		// set a custom color if you have a perfect sick combo
		var perfectSickString:String = "";
		if ((allSicks) && (daRating == "sick"))
			perfectSickString = "-perfect";
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss ratings can pop, and they dont mess with your sick combo
		 */

		var noTiming:Bool = false;
		if ((daRating == "sick") || (daRating == "miss"))
			noTiming = true;

		var rating = ForeverAssets.generateRating('ratings/$daRating$perfectSickString', assetModifier, 'UI', ratingsGroup);

		// this has to be loaded after unfortunately as much as I like to condense all of my code down
		if (assetModifier == 'basepixel' || assetModifier == 'foreverpixel')
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		else
		{
			rating.antialiasing = true;
			rating.setGraphicSize(Std.int(rating.width * 0.7));
		}

		add(rating);

		// ooof this is very bad
		if (!noTiming)
		{
			var timing = timingsGroup.recycle(FlxSprite);
			timingsGroup.add(timing);
			// rating timing
			// setting the width, it's half of the sprite's width, I don't like doing this but that code scares me in terms of optimisations
			var newWidth = 166;
			if (assetModifier == 'basepixel' || assetModifier == 'foreverpixel')
				newWidth = 26;

			timing.loadGraphic(Paths.image(ForeverTools.returnSkinAsset('ratings/$daRating-timings', assetModifier, 'UI')), true, newWidth);
			timing.alpha = 1;
			// this code is quickly becoming painful lmao
			timing.animation.add('early', [0]);
			timing.animation.add('late', [1]);
			timing.animation.play(ratingTiming);

			timing.x = rating.x;
			timing.y = rating.y;
			timing.acceleration.y = rating.acceleration.y;
			timing.velocity.y = rating.velocity.y;
			timing.velocity.x = rating.velocity.x;

			// messy messy pixel stuffs
			// but thank you pixl your timings are awesome
			if (assetModifier == 'basepixel' || assetModifier == 'foreverpixel')
			{
				// positions are stupid
				timing.x += (newWidth / 2) * daPixelZoom;
				timing.setGraphicSize(Std.int(timing.width * daPixelZoom * 0.7));
				if (ratingTiming != 'late')
					timing.x -= newWidth * 0.5 * daPixelZoom;
			}
			else
			{
				timing.antialiasing = true;
				timing.setGraphicSize(Std.int(timing.width * 0.7));
				if (ratingTiming == 'late')
					timing.x += newWidth * 0.5;
			}

			add(timing);

			FlxTween.tween(timing, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					timing.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}

		///*
		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rating.kill();
			},
			startDelay: Conductor.crochet * 0.00125
		});
		// */
	}

	function goodNoteHit(coolNote:Note, character:Character, characterStrums:FlxTypedGroup<UIStaticArrow>, ?canDisplayRating:Bool = true)
	{
		if (!coolNote.wasGoodHit)
		{
			coolNote.wasGoodHit = true;
			vocals.volume = 1;

			if (canDisplayRating)
			{
				// we'll need to call the rating here as it will also be used to determine health
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);
				// also thanks sammu :mariocool:

				// call the ratings over from the timing class
				var daRatings = Timings.daRatings;

				var foundRating = false;
				// loop through all avaliable ratings
				var baseRating:String = "sick";
				for (myRating in daRatings.keys())
				{
					if ((daRatings.get(myRating)[0] != null)
						&& (((noteDiff > Conductor.safeZoneOffset * daRatings.get(myRating)[0])) && (!foundRating)))
					{
						// get the timing
						if (coolNote.strumTime < Conductor.songPosition)
							ratingTiming = "late";
						else
							ratingTiming = "early";

						// call the rating itself
						baseRating = myRating;
						foundRating = true;
					}
				}

				if (!coolNote.isSustainNote)
				{
					increaseCombo();
					popUpScore(daRatings, baseRating, coolNote);
					// health += 0.023;
				}
				else if (coolNote.isSustainNote)
				{
					// health += 0.004;
					// call updated accuracy stuffs
					Timings.updateAccuracy(100);
				}
				healthCall(true, coolNote, daRatings.get(baseRating)[3]);
			}

			characterPlayAnimation(coolNote, character);
			characterStrums.members[coolNote.noteData].playAnim('confirm', true);

			if (!coolNote.isSustainNote)
			{
				coolNote.callMods();
				coolNote.kill();
				notes.remove(coolNote, true);
				coolNote.destroy();
			}
			//
		}
	}

	function healthCall(increase:Bool, ?coolNote:Note, ?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.024 * 2.5;

		// self explanatory checks
		if (increase)
		{
			//
			var trueHealth = healthBase * 0.75;
			if ((coolNote.isSustainNote) && (coolNote.animation.name.endsWith('holdend')))
				health += trueHealth;
			else if (!coolNote.isSustainNote)
				health += trueHealth * (ratingMultiplier / 100);
		}
		else
			health -= healthBase;
	}

	function missNoteCheck(direction:Int = 0, pressControls:Array<Bool>, character:Character)
	{
		if (pressControls[direction])
		{
			healthCall(false);
			var stringDirection:String = UIStaticArrow.getArrowFromNumber(direction);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			character.playAnim('sing' + stringDirection.toUpperCase() + 'miss');

			decreaseCombo();
			//
		}
	}

	function characterPlayAnimation(coolNote:Note, character:Character)
	{
		// alright so we determine which animation needs to play
		// get alt strings and stuffs
		var stringArrow:String = '';
		var altString:String = '';

		var baseString = 'sing' + UIStaticArrow.getArrowFromNumber(coolNote.noteData).toUpperCase();

		// I tried doing xor and it didnt work lollll
		if (coolNote.noteAlt > 0)
			altString = '-alt';
		if (((SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim))
			&& (character.animOffsets.exists(baseString + '-alt')))
		{
			if (altString != '-alt')
				altString = '-alt';
			else
				altString = '';
		}

		stringArrow = baseString + altString;
		if (coolNote.foreverMods.get('string')[0] != "")
			stringArrow = coolNote.noteString;

		character.playAnim(stringArrow, true);
		character.holdTimer = 0;
	}

	//
	//
	//	please spare me
	//
	//

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			songMusic.play();
			songMusic.onComplete = endSong;
			vocals.play();

			#if desktop
			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;

			// Updating Discord Rich Presence (with Time Left)
			// DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
			#end
		}
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		songMusic = new FlxSound().loadEmbedded(Paths.inst(SONG.song));

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		// here's where the chart loading takes place
		notes = new FlxTypedGroup<Note>();
		add(notes);

		// generate the chart
		// much simpler looking than in the original game lol
		ChartLoader.generateChartType(determinedChartType);

		// return the unspawned notes that were generated in said chart
		unspawnNotes = [];
		unspawnNotes = ChartLoader.returnUnspawnNotes();
		ChartLoader.flushUnspawnNotes();

		// sort through them
		unspawnNotes.sort(sortByShit);
		// give the game the heads up to be able to start
		generatedMusic = true;

		Timings.accuracyMaxCalculation(unspawnNotes);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			// var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var babyArrow:UIStaticArrow = ForeverAssets.generateUIArrows(0, strumLine.members[Math.floor(i + (player * 4))].y - 25, i, assetModifier);
			babyArrow.ID = i; // + (player * 4);

			switch (player)
			{
				case 1:
					boyfriendStrums.add(babyArrow);
				default:
					dadStrums.add(babyArrow);
			}

			babyArrow.x += 75;
			babyArrow.x += Note.swagWidth * i;
			babyArrow.x += ((FlxG.width / 2) * player);

			babyArrow.initialX = Math.floor(babyArrow.x);
			babyArrow.initialY = Math.floor(babyArrow.y);

			babyArrow.xTo = babyArrow.initialX;
			babyArrow.yTo = babyArrow.initialY;
			babyArrow.angleTo = 0;

			babyArrow.y -= 10;
			babyArrow.playAnim('static');

			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.initialY, alpha: babyArrow.setAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			strumLineNotes.add(babyArrow);

			// generate note splashes
			if (player == 1)
			{
				var noteSplash:NoteSplash = ForeverAssets.generateNoteSplashes('notes/noteSplashes', assetModifier, 'UI', i);
				noteSplash.x += Note.swagWidth * i;
				noteSplash.x += ((FlxG.width / 2) * player);
				splashNotes.add(noteSplash);
			}
		}
		//
	}

	//
	// I need some space okay? this code is claustrophobic as hell
	//

	function resyncVocals():Void
	{
		vocals.pause();

		songMusic.play();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	override function stepHit()
	{
		super.stepHit();
		///*
		if (songMusic.time > Conductor.songPosition + 20 || songMusic.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
		if (curSong == '8-28-63' || curSong == 'prejudice')
		{
			if (curStep >= 576 && curStep < 608 || curStep >= 1856 && curStep < 1888)
			{
					if (curBeat % 0.5 == 0)
					{
						defaultCamZoom += 0.01;	
						
					}
			}
			if (curStep >= 624 && curStep < 640 || curStep >= 1904 && curStep < 1920 )
			{
					if (curBeat % 0.5 == 0)
					{
						defaultCamZoom -= 0.02;	
					}
			}
			switch (curStep)
			{			
			    case 640, 1920:
					defaultCamZoom = 1.2;
				case 1152, 2432:
					defaultCamZoom = 0.8;
			}
		}
		//*/
	}
	
	private function charactersDance(curBeat:Int)
	{
		if ((curBeat % gfSpeed == 0) && (!gf.animation.curAnim.name.startsWith("sing")))
			gf.dance();

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			boyfriend.dance();

		// added this for opponent cus it wasn't here before and skater would just freeze
		if (!dadOpponent.animation.curAnim.name.startsWith("sing"))
			dadOpponent.dance();
	}

	override function beatHit()
	{
		super.beatHit();

		if ((FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) && (!Init.gameSettings.get('Reduced Movements')[0]))
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.05;
		}
		if (curSong.toLowerCase() == '8-28-63' && curBeat >= 160 && curBeat < 290 || curBeat >= 480 && curBeat < 572 || curBeat >= 576 && curBeat < 600  && FlxG.camera.zoom < 1.7)
		{
			FlxG.camera.zoom += 0.5;
			camHUD.zoom += 0.02;
		}

		if (curSong.toLowerCase() == 'prejudice' && curBeat >= 160 && curBeat < 290 || curBeat >= 480 && curBeat < 572 || curBeat >= 576 && curBeat < 600  && FlxG.camera.zoom < 1.7)
		{
			FlxG.camera.zoom += 0.5;
			camHUD.zoom += 0.02;
		}
		uiHUD.beatHit();

		//
		charactersDance(curBeat);

		// stage stuffs
		stageBuild.stageUpdate(curBeat, curStep, boyfriend, gf, dadOpponent);
	}

	//
	//
	/// substate stuffs
	//
	//

	public static function resetMusic()
	{
		// simply stated, resets the playstate's music for other states and substates
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			// trace('null song');
			if (songMusic != null)
			{
				//	trace('nulled song');
				songMusic.pause();
				vocals.pause();
				//	trace('nulled song finished');
			}

			// trace('ui shit break');
			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = false;
		}

		// trace('open substate');
		super.openSubState(SubState);
		// trace('open substate end ');
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (songMusic != null && !startingSong)
				resyncVocals();

			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = true;
			paused = false;

			/*
				#if desktop
				if (startTimer.finished)
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
				}
				else
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				}
				#end
				// */
		}

		super.closeSubState();
	}

	/*
		Extra functions and stuffs
	 */
	/// song end function at the end of the playstate lmao ironic I guess
	private var endSongEvent:Bool = false;

	function endSong():Void
	{
		#if android
		androidControls.visible = false;
		#end
		canPause = false;
		songMusic.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (!isStoryMode)
			Main.switchState(new FreeplayState());
		else
		{
			// set the campaign's score higher
			campaignScore += songScore;

			// remove a song from the story playlist
			storyPlaylist.remove(storyPlaylist[0]);

			// check if there aren't any songs left
			if ((storyPlaylist.length <= 0) && (!endSongEvent))
			{
				// play menu music
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				// set up transitions
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// change to the menu state
				Main.switchState(new StoryMenuState());

				// save the week's score if the score is valid
				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				// flush the save
				FlxG.save.flush();
			}
			else
				songEndSpecificActions();
		}
		//
	}

	private function songEndSpecificActions()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'eggnog':
				// make the lights go out
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;

				// oooo spooky
				FlxG.sound.play(Paths.sound('Lights_Shut_off'));

				// call the song end
				var eggnogEndTimer:FlxTimer = new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer)
				{
					callDefaultSongEnd();
				}, 1);

			default:
				callDefaultSongEnd();
		}
	}

	private function callDefaultSongEnd()
	{
		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase();
		difficulty = difficulty.replace('-normal', '');

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		ForeverTools.killMusic([songMusic, vocals]);

		Main.switchState(new PlayState());
	}

	public function songIntroCutscene()
	{
		switch (curSong.toLowerCase())
		{
			case "winter-horrorland":
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					remove(blackScreen);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				});
			case 'roses':
				FlxG.sound.play(Paths.sound('ANGRY'));
			// schoolIntro(doof);
			default:
				if (Assets.exists(Paths.txt(SONG.song.toLowerCase() + '/' + SONG.song.toLowerCase() + 'Dialogue')))
					DialogueBox.createDialogue(CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/' + SONG.song.toLowerCase() + 'Dialogue')));
				else
					startCountdown();
		}
		//
	}

	public static var swagCounter:Int = 0;

	private function startCountdown():Void
	{
		//Application.current.window.alert('test', 'test06');
		#if android
		androidControls.visible = true;
		#end
		//Application.current.window.alert('test', 'test07');
		Conductor.songPosition = -(Conductor.crochet * 5);
		swagCounter = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			beatHit();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['UI/$assetModifier/ready', 'UI/$assetModifier/set', 'UI/$assetModifier/go']);

			var introAlts:Array<String> = introAssets.get('default');
			for (value in introAssets.keys())
			{
				if (value == PlayState.curStage)
					introAlts = introAssets.get(value);
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (assetModifier == 'basepixel' || assetModifier == 'foreverpixel')
						ready.setGraphicSize(Std.int(ready.width * PlayState.daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (assetModifier == 'basepixel' || assetModifier == 'foreverpixel')
						set.setGraphicSize(Std.int(set.width * PlayState.daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (assetModifier == 'basepixel' || assetModifier == 'foreverpixel')
						go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
		//Application.current.window.alert('test', 'test08');
	}
}
