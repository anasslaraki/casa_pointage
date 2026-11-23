// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loading_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoadingState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoadingState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoadingState()';
}


}

/// @nodoc
class $LoadingStateCopyWith<$Res>  {
$LoadingStateCopyWith(LoadingState _, $Res Function(LoadingState) __);
}


/// Adds pattern-matching-related methods to [LoadingState].
extension LoadingStatePatterns on LoadingState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LOADING value)?  loading,TResult Function( EMPTY value)?  empty,TResult Function( ERROR value)?  error,TResult Function( LOADED value)?  loaded,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LOADING() when loading != null:
return loading(_that);case EMPTY() when empty != null:
return empty(_that);case ERROR() when error != null:
return error(_that);case LOADED() when loaded != null:
return loaded(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LOADING value)  loading,required TResult Function( EMPTY value)  empty,required TResult Function( ERROR value)  error,required TResult Function( LOADED value)  loaded,}){
final _that = this;
switch (_that) {
case LOADING():
return loading(_that);case EMPTY():
return empty(_that);case ERROR():
return error(_that);case LOADED():
return loaded(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LOADING value)?  loading,TResult? Function( EMPTY value)?  empty,TResult? Function( ERROR value)?  error,TResult? Function( LOADED value)?  loaded,}){
final _that = this;
switch (_that) {
case LOADING() when loading != null:
return loading(_that);case EMPTY() when empty != null:
return empty(_that);case ERROR() when error != null:
return error(_that);case LOADED() when loaded != null:
return loaded(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function()?  empty,TResult Function( String? message,  MessageType? type)?  error,TResult Function( String? message,  MessageType? type)?  loaded,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LOADING() when loading != null:
return loading();case EMPTY() when empty != null:
return empty();case ERROR() when error != null:
return error(_that.message,_that.type);case LOADED() when loaded != null:
return loaded(_that.message,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function()  empty,required TResult Function( String? message,  MessageType? type)  error,required TResult Function( String? message,  MessageType? type)  loaded,}) {final _that = this;
switch (_that) {
case LOADING():
return loading();case EMPTY():
return empty();case ERROR():
return error(_that.message,_that.type);case LOADED():
return loaded(_that.message,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function()?  empty,TResult? Function( String? message,  MessageType? type)?  error,TResult? Function( String? message,  MessageType? type)?  loaded,}) {final _that = this;
switch (_that) {
case LOADING() when loading != null:
return loading();case EMPTY() when empty != null:
return empty();case ERROR() when error != null:
return error(_that.message,_that.type);case LOADED() when loaded != null:
return loaded(_that.message,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class LOADING implements LoadingState {
  const LOADING();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LOADING);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoadingState.loading()';
}


}




/// @nodoc


class EMPTY implements LoadingState {
  const EMPTY();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EMPTY);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoadingState.empty()';
}


}




/// @nodoc


class ERROR implements LoadingState {
  const ERROR({this.message, this.type});
  

 final  String? message;
 final  MessageType? type;

/// Create a copy of LoadingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ERRORCopyWith<ERROR> get copyWith => _$ERRORCopyWithImpl<ERROR>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ERROR&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,message,type);

@override
String toString() {
  return 'LoadingState.error(message: $message, type: $type)';
}


}

/// @nodoc
abstract mixin class $ERRORCopyWith<$Res> implements $LoadingStateCopyWith<$Res> {
  factory $ERRORCopyWith(ERROR value, $Res Function(ERROR) _then) = _$ERRORCopyWithImpl;
@useResult
$Res call({
 String? message, MessageType? type
});




}
/// @nodoc
class _$ERRORCopyWithImpl<$Res>
    implements $ERRORCopyWith<$Res> {
  _$ERRORCopyWithImpl(this._self, this._then);

  final ERROR _self;
  final $Res Function(ERROR) _then;

/// Create a copy of LoadingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? type = freezed,}) {
  return _then(ERROR(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType?,
  ));
}


}

/// @nodoc


class LOADED implements LoadingState {
  const LOADED({this.message, this.type});
  

 final  String? message;
 final  MessageType? type;

/// Create a copy of LoadingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LOADEDCopyWith<LOADED> get copyWith => _$LOADEDCopyWithImpl<LOADED>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LOADED&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,message,type);

@override
String toString() {
  return 'LoadingState.loaded(message: $message, type: $type)';
}


}

/// @nodoc
abstract mixin class $LOADEDCopyWith<$Res> implements $LoadingStateCopyWith<$Res> {
  factory $LOADEDCopyWith(LOADED value, $Res Function(LOADED) _then) = _$LOADEDCopyWithImpl;
@useResult
$Res call({
 String? message, MessageType? type
});




}
/// @nodoc
class _$LOADEDCopyWithImpl<$Res>
    implements $LOADEDCopyWith<$Res> {
  _$LOADEDCopyWithImpl(this._self, this._then);

  final LOADED _self;
  final $Res Function(LOADED) _then;

/// Create a copy of LoadingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,Object? type = freezed,}) {
  return _then(LOADED(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType?,
  ));
}


}

// dart format on
