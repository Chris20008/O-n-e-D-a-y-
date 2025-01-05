// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again:
// With a Flutter package, run `flutter pub run build_runner build`.
// With a Dart package, run `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'util/objectbox/ob_exercise.dart';
import 'util/objectbox/ob_sick_days.dart';
import 'util/objectbox/ob_workout.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 2510276494793380538),
      name: 'ObExercise',
      lastPropertyId: const obx_int.IdUid(11, 3217034757361258893),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 9168677633838207019),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 5921422946981106093),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 587912730100271835),
            name: 'amounts',
            type: 27,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 5749807508740524100),
            name: 'weights',
            type: 29,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 2424955615328354415),
            name: 'restInSeconds',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 7754348514525411391),
            name: 'seatLevel',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 4909574619532409130),
            name: 'linkName',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(9, 2676033552247713648),
            name: 'setTypes',
            type: 27,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(11, 3217034757361258893),
            name: 'category',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(3, 6190945827968541021),
      name: 'ObWorkout',
      lastPropertyId: const obx_int.IdUid(6, 8375506305716248786),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 6360518187727305876),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 8119469040078393535),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 8413082881233068640),
            name: 'date',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 2684771545934192254),
            name: 'isTemplate',
            type: 1,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 8375506305716248786),
            name: 'linkedExercises',
            type: 30,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[
        obx_int.ModelRelation(
            id: const obx_int.IdUid(3, 979565396682663220),
            name: 'exercises',
            targetId: const obx_int.IdUid(2, 2510276494793380538))
      ],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(4, 3149227828482375570),
      name: 'ObSickDays',
      lastPropertyId: const obx_int.IdUid(3, 2028011289927285168),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 423700910599777290),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 7878206278239994477),
            name: 'startDate',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 2028011289927285168),
            name: 'endDate',
            type: 10,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(4, 3149227828482375570),
      lastIndexId: const obx_int.IdUid(0, 0),
      lastRelationId: const obx_int.IdUid(4, 6635772398473233360),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [4145133195816181644],
      retiredIndexUids: const [],
      retiredPropertyUids: const [
        204025455119346967,
        7663215118549214280,
        5422671899604002301,
        425489130545911071,
        2715976310809358031,
        2508751927511525074
      ],
      retiredRelationUids: const [
        1856206922338472012,
        8918878201698632752,
        6635772398473233360
      ],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    ObExercise: obx_int.EntityDefinition<ObExercise>(
        model: _entities[0],
        toOneRelations: (ObExercise object) => [],
        toManyRelations: (ObExercise object) => {},
        getId: (ObExercise object) => object.id,
        setId: (ObExercise object, int id) {
          object.id = id;
        },
        objectToFB: (ObExercise object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          final amountsOffset = fbb.writeListInt64(object.amounts);
          final weightsOffset = fbb.writeListFloat64(object.weights);
          final linkNameOffset = object.linkName == null
              ? null
              : fbb.writeString(object.linkName!);
          final setTypesOffset = fbb.writeListInt64(object.setTypes);
          fbb.startTable(12);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.addOffset(3, amountsOffset);
          fbb.addOffset(4, weightsOffset);
          fbb.addInt64(5, object.restInSeconds);
          fbb.addInt64(6, object.seatLevel);
          fbb.addOffset(7, linkNameOffset);
          fbb.addOffset(8, setTypesOffset);
          fbb.addInt64(10, object.category);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final weightsParam =
              const fb.ListReader<double>(fb.Float64Reader(), lazy: false)
                  .vTableGet(buffer, rootOffset, 12, []);
          final amountsParam =
              const fb.ListReader<int>(fb.Int64Reader(), lazy: false)
                  .vTableGet(buffer, rootOffset, 10, []);
          final restInSecondsParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 14, 0);
          final setTypesParam =
              const fb.ListReader<int>(fb.Int64Reader(), lazy: false)
                  .vTableGet(buffer, rootOffset, 20, []);
          final seatLevelParam =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 16);
          final linkNameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 18);
          final categoryParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 24, 0);
          final object = ObExercise(
              id: idParam,
              name: nameParam,
              weights: weightsParam,
              amounts: amountsParam,
              restInSeconds: restInSecondsParam,
              setTypes: setTypesParam,
              seatLevel: seatLevelParam,
              linkName: linkNameParam,
              category: categoryParam);

          return object;
        }),
    ObWorkout: obx_int.EntityDefinition<ObWorkout>(
        model: _entities[1],
        toOneRelations: (ObWorkout object) => [],
        toManyRelations: (ObWorkout object) =>
            {obx_int.RelInfo<ObWorkout>.toMany(3, object.id): object.exercises},
        getId: (ObWorkout object) => object.id,
        setId: (ObWorkout object, int id) {
          object.id = id;
        },
        objectToFB: (ObWorkout object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          final linkedExercisesOffset = fbb.writeList(object.linkedExercises
              .map(fbb.writeString)
              .toList(growable: false));
          fbb.startTable(7);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.addInt64(2, object.date.millisecondsSinceEpoch);
          fbb.addBool(3, object.isTemplate);
          fbb.addOffset(5, linkedExercisesOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final dateParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0));
          final isTemplateParam =
              const fb.BoolReader().vTableGet(buffer, rootOffset, 10, false);
          final linkedExercisesParam = const fb.ListReader<String>(
                  fb.StringReader(asciiOptimization: true),
                  lazy: false)
              .vTableGet(buffer, rootOffset, 14, []);
          final object = ObWorkout(
              id: idParam,
              name: nameParam,
              date: dateParam,
              isTemplate: isTemplateParam,
              linkedExercises: linkedExercisesParam);
          obx_int.InternalToManyAccess.setRelInfo<ObWorkout>(object.exercises,
              store, obx_int.RelInfo<ObWorkout>.toMany(3, object.id));
          return object;
        }),
    ObSickDays: obx_int.EntityDefinition<ObSickDays>(
        model: _entities[2],
        toOneRelations: (ObSickDays object) => [],
        toManyRelations: (ObSickDays object) => {},
        getId: (ObSickDays object) => object.id,
        setId: (ObSickDays object, int id) {
          object.id = id;
        },
        objectToFB: (ObSickDays object, fb.Builder fbb) {
          fbb.startTable(4);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.startDate.millisecondsSinceEpoch);
          fbb.addInt64(2, object.endDate.millisecondsSinceEpoch);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final startDateParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0));
          final endDateParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0));
          final object = ObSickDays(
              id: idParam, startDate: startDateParam, endDate: endDateParam);

          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [ObExercise] entity fields to define ObjectBox queries.
class ObExercise_ {
  /// see [ObExercise.id]
  static final id =
      obx.QueryIntegerProperty<ObExercise>(_entities[0].properties[0]);

  /// see [ObExercise.name]
  static final name =
      obx.QueryStringProperty<ObExercise>(_entities[0].properties[1]);

  /// see [ObExercise.amounts]
  static final amounts =
      obx.QueryIntegerVectorProperty<ObExercise>(_entities[0].properties[2]);

  /// see [ObExercise.weights]
  static final weights =
      obx.QueryDoubleVectorProperty<ObExercise>(_entities[0].properties[3]);

  /// see [ObExercise.restInSeconds]
  static final restInSeconds =
      obx.QueryIntegerProperty<ObExercise>(_entities[0].properties[4]);

  /// see [ObExercise.seatLevel]
  static final seatLevel =
      obx.QueryIntegerProperty<ObExercise>(_entities[0].properties[5]);

  /// see [ObExercise.linkName]
  static final linkName =
      obx.QueryStringProperty<ObExercise>(_entities[0].properties[6]);

  /// see [ObExercise.setTypes]
  static final setTypes =
      obx.QueryIntegerVectorProperty<ObExercise>(_entities[0].properties[7]);

  /// see [ObExercise.category]
  static final category =
      obx.QueryIntegerProperty<ObExercise>(_entities[0].properties[8]);
}

/// [ObWorkout] entity fields to define ObjectBox queries.
class ObWorkout_ {
  /// see [ObWorkout.id]
  static final id =
      obx.QueryIntegerProperty<ObWorkout>(_entities[1].properties[0]);

  /// see [ObWorkout.name]
  static final name =
      obx.QueryStringProperty<ObWorkout>(_entities[1].properties[1]);

  /// see [ObWorkout.date]
  static final date =
      obx.QueryDateProperty<ObWorkout>(_entities[1].properties[2]);

  /// see [ObWorkout.isTemplate]
  static final isTemplate =
      obx.QueryBooleanProperty<ObWorkout>(_entities[1].properties[3]);

  /// see [ObWorkout.linkedExercises]
  static final linkedExercises =
      obx.QueryStringVectorProperty<ObWorkout>(_entities[1].properties[4]);

  /// see [ObWorkout.exercises]
  static final exercises =
      obx.QueryRelationToMany<ObWorkout, ObExercise>(_entities[1].relations[0]);
}

/// [ObSickDays] entity fields to define ObjectBox queries.
class ObSickDays_ {
  /// see [ObSickDays.id]
  static final id =
      obx.QueryIntegerProperty<ObSickDays>(_entities[2].properties[0]);

  /// see [ObSickDays.startDate]
  static final startDate =
      obx.QueryDateProperty<ObSickDays>(_entities[2].properties[1]);

  /// see [ObSickDays.endDate]
  static final endDate =
      obx.QueryDateProperty<ObSickDays>(_entities[2].properties[2]);
}
