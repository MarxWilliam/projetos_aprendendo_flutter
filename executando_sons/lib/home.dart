import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AudioPlayer audioPlayer = AudioPlayer();
  AudioPlayer audioPlayerLocal = AudioPlayer();
  AudioCache audioCache = AudioCache(
      prefix: "audios/"); // ele parte da pasta assets bem como está escrito

  Duration _duration1 = Duration(milliseconds: 0);
  Duration _duration2 = Duration(milliseconds: 0);
  Duration _position1 = Duration(milliseconds: 0);
  Duration _position2 = Duration(milliseconds: 0);

  double _volume = 0.5;
  bool primeiraVezRemoto = true;
  bool primeiraVezLocal = true;

  //na aula o professor disse que o play começava sempre do começo mas na versão atual da biblioteca
  // pelo jeito ta começando de onde parou o pause caso ja tenha siudo tocada
  _play() async {
    audioPlayer.setVolume(_volume);
//      int duracao = await audioPlayer.setUrl();
    int result = await audioPlayer
        .play("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3");
    audioPlayer.onDurationChanged.listen((d) => setState(() => _duration1 = d));
    _position();
  }

  _stop() async {
    int result = await audioPlayer.stop();
  }

  _pause() async {
    int result = await audioPlayer.pause();
  }

  _playLocal(String file) async {
    audioPlayerLocal.setVolume(_volume);
    if (primeiraVezLocal) {
      audioPlayerLocal = await audioCache.play(file);

      primeiraVezLocal = false;
    } else {
      int result = await audioPlayerLocal.resume();
    }
    audioPlayerLocal.onDurationChanged
        .listen((d) => setState(() => _duration2 = d));
    _positionLocal();
  }

  // _playLocal(String filePath) async {
  //     if(primeiraVezLocal) {
  //       AudioCache player = AudioCache(prefix: filePath);
  //       player.play('explosion.mp3');
  //       primeiraVezLocal = false;
  //     }
  //     else {
  //       int result = await audioPlayerLocal.resume();
  //     }
  //   }

  _stopLocal() async {
    int result = await audioPlayerLocal.stop();
    primeiraVezLocal = true;
  }

  _pauseLocal() async {
    int result = await audioPlayerLocal.pause();
  }

  _resume() async {
    int result = await audioPlayer.resume();
  }
  //
  // _duration1F() {
  //   audioPlayer.onDurationChanged.listen((Duration d) {
  //     setState(() => _duration1 = d);
  //   });
  // }

  // Future<Duration> _durationF(AudioPlayer player) async {
  //   Duration d = await player.onDurationChanged.lastWhere((element) => false);
  //   return d;
  //   // audioPlayer.onDurationChanged.listen((d) {
  //   //   setState(() => duration1 = d);
  //   // });
  //   // return duration1;
  // }

  _position() {
    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      setState(() => _position1 = p);
    });
  }

  _positionLocal() {
    audioPlayerLocal.onAudioPositionChanged.listen((Duration p) {
      setState(() => _position2 = p);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Executando Sons'),
        backgroundColor: Colors.green,
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  alignment: Alignment.bottomCenter,
                  child: Text("Reprodutor Remoto",
                      style: TextStyle(fontSize: 30))),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                          child: GestureDetector(
                              child: Image(
                                image: AssetImage("assets/images/executar.png"),
                                width: 25,
                              ),
                              onTap: _play)),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: GestureDetector(
                              child: Image(
                                  image: AssetImage("assets/images/pausar.png"),
                                  width: 25),
                              onTap: _pause)),
                      Padding(
                          padding: EdgeInsets.all(10),
                          child: GestureDetector(
                              child: Image(
                                  image: AssetImage("assets/images/parar.png"),
                                  width: 25),
                              onTap: _stop)),
                    ],
                  )),
                  Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      alignment: Alignment.center,
                      child: Text(
                          "Duraçãp " +
                              (_duration1.inSeconds / 60).toString() +
                              " min " +
                              (_duration1.inSeconds % 60).toString() +
                              " sec",
                          style: TextStyle(fontSize: 15))),
                ],
              )),
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(0),
                  child: Slider(
                      min: 0,
                      max: _duration1.inSeconds.toDouble() > 0
                          ? _duration1.inSeconds.toDouble()
                          : 1,
                      divisions: _duration1.inSeconds.toInt() > 0
                          ? _duration1.inSeconds.toInt()
                          : 1,
                      value: _position1.inSeconds.toDouble() > 1
                          ? _position1.inSeconds.toDouble()
                          : 0,
                      activeColor: Colors.blueAccent,
                      inactiveColor: Colors.lightGreen,
                      onChanged: (double time) async {
                        setState(() {
                          _position1 = new Duration(seconds: time.toInt());
                        });
                        int result = await audioPlayer.seek(_position1);
                      })),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 70, 20),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    (_position1.inSeconds ~/ 60).toInt().toString() +
                        " min " +
                        (_position1.inSeconds % 60).toString() +
                        " sec",
                    style: TextStyle(fontSize: 20),
                  )),
              Container(
                  padding: EdgeInsets.only(bottom: 20),
                  alignment: Alignment.bottomCenter,
                  child:
                      Text("Reprodutor Local", style: TextStyle(fontSize: 30))),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: GestureDetector(
                      child: Image(
                        image: AssetImage("assets/images/executar.png"),
                        width: 25,
                      ),
                      onTap: () {
                        _playLocal("musica.mp3");
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: GestureDetector(
                      child: Image(
                        image: AssetImage("assets/images/pausar.png"),
                        width: 25,
                      ),
                      onTap: () {
                        _pauseLocal();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: GestureDetector(
                      child: Image(
                          image: AssetImage("assets/images/parar.png"),
                          width: 25),
                      onTap: () {
                        _stopLocal();
                      },
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      alignment: Alignment.center,
                      child: Text(
                          "Duraçãp " +
                              (_duration2.inSeconds ~/ 60).toString() +
                              " min " +
                              (_duration2.inSeconds % 60).toString() +
                              " sec",
                          style: TextStyle(fontSize: 15))),
                ],
              ),
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(0),
                  child: Slider(
                      min: 0,
                      max: _duration2.inSeconds.toDouble() > 0
                          ? _duration2.inSeconds.toDouble()
                          : 1,
                      divisions: _duration2.inSeconds.toInt() > 0
                          ? _duration2.inSeconds.toInt()
                          : 1,
                      value: _position2.inSeconds.toDouble() > 0
                          ? _position2.inSeconds.toDouble()
                          : 0,
                      activeColor: Colors.blueAccent,
                      inactiveColor: Colors.lightGreen,
                      onChanged: (double time) async {
                        setState(() {
                          _position2 = new Duration(seconds: time.toInt());
                        });
                        int result = await audioPlayerLocal.seek(_position2);
                      })),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 70, 20),
                  alignment: Alignment.bottomRight,
                  child: Text(
                    (_position2.inSeconds ~/ 60).toInt().toString() +
                        " min " +
                        (_position2.inSeconds % 60).toString() +
                        " sec",
                    style: TextStyle(fontSize: 20),
                  )),
              Text("Volume", style: TextStyle(fontSize: 25)),
              Slider(
                value: _volume,
                label: _volume.toString(),
                min: 0,
                max: 1,
                onChanged: (novoVolume) {
                  setState(() {
                    _volume = novoVolume;
                  });
                  audioPlayer.setVolume(_volume);
                  audioPlayerLocal.setVolume(_volume);
                },
              ),
            ],
          )),
    );
  }
}
