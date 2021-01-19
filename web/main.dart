import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:math';
import 'package:http/http.dart' as http;

class Point3D {
  final num x, y, z;

  const Point3D(this.x, this.y, this.z);

  @override
  String toString() => '[$x, $y, $z]';
}

Future<List<Point3D>> getPoints() async {
  final data = await http.get('coords.json');
  if (data.statusCode != 200) {
    throw data.statusCode;
  } else {
    final list = json.decode(data.body);
    return List.generate(list.length,
        (index) => Point3D(list[index][0], -list[index][2], list[index][1]));
  }
}

void rotate(num xPos, Element output) {
  output.style.setProperty('--rotate', '${xPos}deg');
}

final List<String> colours =
    List.generate(500, (index) => 'hsl(0deg, 100%, 50%');

void main() async {
  final DivElement output = querySelector('#output');

  document.body.addEventListener('mousemove', (event) {
    final e = event as MouseEvent;
    rotate(e.client.x / window.innerWidth * 360 - 180, output);
  });

  final points = await getPoints();
  output.style.perspective = '1000px';

  final List<Element> elements = [];
  for (var n = 0; n < points.length; ++n) {
    final i = points[n];
    final DivElement newEl = window.document.createElement('div');
    newEl.className = 'point';
    newEl.style.color = colours[n];
    final angle = atan2(i.x, i.z);
    newEl.style.transform =
        'rotateY(var(--rotate)) translate3D(${i.x}px, ${i.y}px, ${i.z}px) rotateY(${angle}rad)';
    output.append(newEl);
    elements.add(newEl);
  }

  Timer.periodic(Duration(milliseconds: 16), (timer) {
    animateTick(timer, points, elements);
  });
}

void animateTick(Timer time, List<Point3D> points, List<Element> elements) {
  for (var i = 0; i < 500; ++i) {
    var hue = points[i].x > 0 ? 90 : 0;

    elements[i].style.color = 'hsl(${hue % 360}, 100%, 50%)';
  }
}
