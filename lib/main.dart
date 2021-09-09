import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const TabBarDemo());
}

generateRandomColor() => Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

class Model {
  final num;

  Model({this.num});
}

class ModelWidget extends StatelessWidget {
  final Model model;

  ModelWidget(this.model) : super();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
          color: generateRandomColor(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                model.num.toString(),
                textAlign: TextAlign.center,
              ),
            ],
          )),
    );
  }
}

class TabBarDemo extends StatelessWidget {
  const TabBarDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ------------------------------- given ----------------------------------
    const CROSS_AXIS_COUNT = 6;
    const CROSS_AXIS_SPACING = 10.0;
    const MAIN_AXIS_SPACING = 10.0;
    final models = List.generate(20, (_) => Model(num: Random().nextInt(100)));
    // ------------------------------------------------------------------------
    // ------------------------------ solution --------------------------------
    final modelCount = models.length;
    final int fittingCount = modelCount - modelCount % CROSS_AXIS_COUNT;
    // ------------------------------------------------------------------------

    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  child: Text("problem"),
                ),
                Tab(
                  child: Text("solution (static)"),
                ),
                Tab(icon: Text("solution (builder)")),
              ],
            ),
            title: const Text('staggered_grid - centering tiles'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBarView(
              children: [
                // ------------------------------ problem ---------------------------------
                Scaffold(
                  body: StaggeredGridView.count(
                    crossAxisCount: CROSS_AXIS_COUNT,
                    shrinkWrap: true,
                    mainAxisSpacing: MAIN_AXIS_SPACING,
                    crossAxisSpacing: CROSS_AXIS_SPACING,
                    staggeredTiles: models.map((m) => StaggeredTile.fit(1)).toList(),
                    children: models.map((m) => ModelWidget(m)).toList(),
                  ),
                ),
                // ------------------------------------------------------------------------
                // ------------------------- solution (static) ----------------------------
                Scaffold(
                  body: LayoutBuilder(builder: (context, constraints) {
                    return StaggeredGridView.count(
                      crossAxisCount: CROSS_AXIS_COUNT,
                      shrinkWrap: true,
                      mainAxisSpacing: MAIN_AXIS_SPACING,
                      crossAxisSpacing: CROSS_AXIS_SPACING,
                      staggeredTiles: [
                        ...models.sublist(0, fittingCount).map((m) => StaggeredTile.fit(1)).toList(),
                        if (modelCount != fittingCount) StaggeredTile.fit(CROSS_AXIS_COUNT)
                      ],
                      children: [
                        ...models.sublist(0, fittingCount).map((m) => ModelWidget(m)).toList(),
                        if (modelCount != fittingCount)
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: models.sublist(fittingCount, modelCount).map((m) {
                                return Container(
                                    width: constraints.maxWidth / CROSS_AXIS_COUNT - CROSS_AXIS_SPACING,
                                    child: ModelWidget(m));
                              }).toList())
                      ],
                    );
                  }),
                ),
                // ------------------------------------------------------------------------
                // ------------------------- solution (builder) ---------------------------
                Scaffold(
                  body: LayoutBuilder(builder: (context, constraints) {
                    return StaggeredGridView.countBuilder(
                        crossAxisCount: CROSS_AXIS_COUNT,
                        shrinkWrap: true,
                        mainAxisSpacing: MAIN_AXIS_SPACING,
                        crossAxisSpacing: CROSS_AXIS_SPACING,
                        itemCount: modelCount == fittingCount ? fittingCount : fittingCount + 1,
                        itemBuilder: (context, index) {
                          if (index < fittingCount) {
                            return ModelWidget(models.elementAt(index));
                          } else {
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: models.sublist(fittingCount, modelCount).map((m) {
                                  return Container(
                                      width: constraints.maxWidth / CROSS_AXIS_COUNT - CROSS_AXIS_SPACING,
                                      child: ModelWidget(m));
                                }).toList());
                          }
                        },
                        staggeredTileBuilder: (int index) {
                          if (index < fittingCount) {
                            return StaggeredTile.count(1, 1);
                          } else {
                            return StaggeredTile.count(CROSS_AXIS_COUNT, 1);
                          }
                        });
                  }),
                ),
                // ------------------------------------------------------------------------
              ],
            ),
          ),
        ),
      ),
    );
  }
}
