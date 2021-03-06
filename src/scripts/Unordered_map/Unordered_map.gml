/*
	Constructors:
		Unordered_map()
		Unordered_map(Arg)
		Unordered_map(Paired-Container)
		Unordered_map(Builtin-Paired-Array)
		Unordered_map(Builtin-Paired-List)
		Unordered_map(Builtin-Map)
		Unordered_map(Arg0, Arg1, ...)

	Initialize:
		new Unordered_map()

	Usage:
		To Iterate values:
			foreach(Container.first(), Container.last(), myfunc)
		
*/
function Unordered_map(): Container() constructor {
#region public
	///@function size()
	static size = function() { return ds_map_size(raw) }

	///@function empty()
	static empty = function() { return ds_map_empty(raw) }

	///@function clear()
	static clear = function() { ds_map_clear(raw) }

	///@function at(key)
	static at = function(K) { return ds_map_find_value(raw, K) }

	///@function front()
	static front = function() {  return at(ds_map_find_first(raw)) }

	///@function back()
	static back = function() { return at(ds_map_find_last(raw)) }

	///@function first()
	static first = function() { return Iterator(ds_map_find_first(raw)) }

	///@function last()
	static last = function() { return undefined }

	///@function insert([key, index])
	static insert_at = function(values) {
		var Key = values[0]
		var Value = values[1]
		ds_map_set(raw, Key, Value)
		return self
	}

	///@function set_at(key, value)
	static set_at = function(K, Value) { ds_map_set(raw, K, Value); return self }

	///@function set_list(key, builtin_list_id)
	static set_list = function(K, Value) { ds_map_add_list(raw, K, Value); return self }

	///@function set_map(key, builtin_map_id)
	static set_map = function(K, Value) { ds_map_add_map(raw, K, Value); return self  }

	///@function erase_at(key)
	static erase_at = function(K) {
		var Temp = at(K)
		ds_map_delete(raw, K)
		return Temp
	}

	///@function seek(value)
	static seek = function(Value) { return find(first(), last(), Value) }

	///@function location(key)
	static location = function(K) { return find(first(), last(), K, function (It, Key) {
		return bool(It[0] == Key)
	})}

	///@function contains(key)
	static contains = function(K) { return ds_map_exists(raw, K) }

	///@function key_swap(key_1, key_2)
	static key_swap = function(Key1, Key2) {
		var Temp = at(Key1)
		ds_map_set(raw, Key1, at(Key2))
		ds_map_set(raw, Key2, Temp)
	}

	///@function is_list(key)
	static is_list = function(K) { return ds_map_is_list(raw, K) }

	///@function is_map(key)
	static is_map = function(K) { return ds_map_is_map(raw, K) }

	///@function read(data_string)
	static read = function(Str) { ds_map_read(raw, Str) }

	///@function write()
	static write = function() { return ds_map_write(raw) }

	///@function destroy()
	static destroy = function() { ds_map_destroy(raw); gc_collect() }

	static type = Unordered_map
	static iterator_type = Bidirectional_iterator
#endregion

#region private
	///@function 
	static underlying_iterator_set = function(Index, Value) { return set_at(Index, Value) }

	///@function 
	static underlying_iterator_get = function(Index) { return [Index, at(Index)] }

	///@function 
	static underlying_iterator_next = function(Index) { return ds_map_find_next(raw, Index) }

	///@function 
	static underlying_iterator_prev = function(Index) { return ds_map_find_previous(raw, Index) }

	///@function 
	static underlying_iterator_insert = undefined

	raw = ds_map_create()
#endregion

	if 0 < argument_count {
		if argument_count == 1 {
			var Item = argument[0]
			if is_array(Item) {
				// (*) Built-in Paired-Array
				for (var i = 0; i < array_length(Item); ++i) insert(Item[i])
			} else if !is_nan(Item) and ds_exists(Item, ds_type_list) {
				// (*) Built-in Paired-List
				for (var i = 0; i < ds_list_size(Item); ++i) insert(Item[| i])
			} else if !is_nan(Item) and ds_exists(Item, ds_type_map) {
				// (*) Built-in Map
				var Size = ds_map_size(Item)
				if 0 < Size {
					var MIt = ds_map_find_first(Item)
					while true {
						insert(MIt, ds_map_find_value(Item, MIt))
						MIt = ds_map_find_next(Item, MIt)
						if is_undefined(MIt)
							break
					}
				}
			} else if is_struct(Item) {
				if is_iterable(Item) {
					// (*) Paired-Container
					foreach(Item.first(), Item.last(), function(Value) {
						insert(Value)
					})
				}
			} else {
				// (*) Arg
				insert(Item)
			}
		} else {
			// (*) Arg0, Arg1, ...
			for (var i = 0; i < argument_count; ++i) insert(argument[i])
		}
	}
}
