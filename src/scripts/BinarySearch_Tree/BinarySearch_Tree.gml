enum BSTree_type {
	none = -1,
	this = 0,
	left,
	right
}

///@function BSTree_node(storage)
function BSTree_node(Storage): Tree_node_tratit() constructor {
	///@function set_parent(node)
	static set_parent = function(Node) { underlying_set_parent(Node) }

	///@function set_left(node)
	static set_left = function(Node) { return underlying_set_left(Node) }

	///@function set_right(node)
	static set_right = function(Node) { return underlying_set_right(Node) }

	///@function set_next(node)
	static set_next = function(Node) {
		if !is_undefined(node_next) {
			node_next.node_previous = undefined
		}
		node_next = Node
		if !is_undefined(Node) {
			Node.node_previous = self
			return true
		}
		return false
	}

	///@function set(value)
	static set = function(Value) { value = Value; return self }

	///@function get()
	static get = function() { return value }

	///@function insert_node(value)
	static insert_node = function(Value) {
		if Value == value {
			return [self, BSTree_type.none]
		} else {
			var Compare = storage.key_inquire_comparator
			if Compare(Value, value) {
				if is_undefined(node_left) {
					var ValueNode = new BSTree_node(storage).set(Value)
					set_left(ValueNode)

					if !is_undefined(node_previous)
						node_previous.set_next(ValueNode)
					ValueNode.set_next(self)

					return [ValueNode, BSTree_type.left]
				} else {
					return node_left.insert_node(Value)
				}
			} else {
				if is_undefined(node_right) {
					var ValueNode = new BSTree_node(storage).set(Value)
					set_right(ValueNode)

					var Promote = parent, ProValue, Upheal
					while !is_undefined(Promote) {
						ProValue = Promote.value
						if Compare(Value, ProValue) {
							ValueNode.set_next(Promote)
							break
						} else {
							Upheal = Promote.parent
							if is_undefined(Upheal)
								break

							Promote = Upheal
						}
					}
					set_next(ValueNode)

					return [ValueNode, BSTree_type.right]
				} else {
					return node_right.insert_node(Value)
				}
			}
		}
	}

	///@function destroy()
	/*
			Splice the case of erasing a key from the Tree.
			
			case 1: a leaf node
				Just remove it.
			
			case 2: the node has one child
				Remove it and pull up its children.
			
			case 3: the node has two children
				Replace it with smallest one and remove the original smallest one.
	*/
	static destroy = function() {
		var Left = node_left, Right = node_right
		var LeftChk = !is_undefined(Left), RightChk = !is_undefined(Right)
		var Is_head = is_undefined(parent)
		var Result = Left

		if LeftChk and RightChk { // two children
			var Leftest = node_next
			var Temp = string(self)
			set(Leftest.value)
			Leftest.destroy()
			delete Leftest
			Result = self
		} else {
			if !is_undefined(node_previous) {
				if !is_undefined(node_next) {
					node_previous.set_next(node_next)
				} else {
					node_previous.set_next(undefined)
				}
			}
			
			if !LeftChk and !RightChk { // has no child
				underlying_destroy()
			} else if LeftChk and !RightChk { // on left, this is the last element in a sequence.
				if Is_head {
					Left.parent = undefined
				} else {
					if self == parent.node_left
						parent.set_left(Left)
					else if self == parent.node_right
						parent.set_right(Left)
				}
				
				underlying_destroy()
				//show_debug_message("Righty: " + string(self))
			} else if !LeftChk and RightChk { // on right
				if Is_head {
					Result = Right
					Right.parent = undefined
				} else {
					if self == parent.node_left
						parent.set_left(Right)
					else if self == parent.node_right
						parent.set_right(Right)
				}
				underlying_destroy()
				//show_debug_message("Lefty: " + string(self))
			}
		}

		gc_collect()
		return Result
	}

	storage = Storage
}

function BinarySearch_tree(): Binary_tree() constructor {
#region public
	///@function front()
	static front = function() { return node_leftest }

	///@function back()
	static back = function() { return node_rightest }

	///@function first()
	static first = function() { return Iterator(node_leftest) }

	///@function last()
	static last = function() { return undefined }

	///@function insert(value)
	static insert = function(Value) {
		if 0 == inner_size {
			inner_size++
			node_head = new BSTree_node(self).set(Value)
			return Iterator(node_head)
		}

		return Iterator(underlying_insert_at_node(node_head, Value))
	}

	///@function insert_at(index, value)
	static insert_at = function(Key, Value) {
		var InsertedNode = underlying_location(Key)
		if !is_undefined(InsertedNode) {
			return Iterator(underlying_insert_at_node(InsertedNode, Value))
		} else {
			return insert(Value)
		}
	}

	///@function insert_iter(iterator, value)
	static insert_iter = function(It, Value) {
		if It.storage != self {
			return undefined
		} else {
			return Iterator(underlying_insert_at_node(It.index, Value))
		}
	}

	///@function erase_at(index)
	static erase_at = function(Key) {
		var Where = underlying_location(Key)
		if !is_undefined(Where)
			underlying_erase_node(Where)
	}

	///@function erase_iter(iterator)
	static erase_iter = function(It) {
		if It.storage == self
			underlying_erase_node(It.index)
	}

	///@function location(value)
	static location = function(Value) {
		var Result = underlying_location(Value)
		
		if is_undefined(Result)
			return undefined
		else
			return Iterator(Result)
	}

	///@function set_key_compare(compare_function)
	static set_key_compare = function(Func) { key_inquire_comparator = method(other, Func) }

	static type = BinarySearch_tree
	static value_type = BSTree_node
	static iterator_type = Bidirectional_iterator
#endregion

#region private
	///@function 
	static extract_key = function(Node) { return Node.value }

	///@function 
	static underlying_insert_at_node = function(Node, Value) {
		var Result = Node.insert_node(Value)
		var Where = Result[0], Branch = Result[1]
		
		if Branch != BSTree_type.none {
			inner_size++
			switch Branch {
			    case BSTree_type.left:
			        if is_undefined(node_leftest) or key_comparator(Where, node_leftest)
						node_leftest = Where
				break

			    case BSTree_type.right:
			        if is_undefined(node_rightest) or !key_comparator(Where, node_rightest)
						node_rightest = Where
				break

			    default:
			        throw "Wrong position of node: " + string(Result)
				break
			}
		}
		return Where
	}

	///@function 
	static underlying_erase_node = function(Node) {
		var Successor = Node.destroy()
		if inner_size == 1
			node_head = undefined
		else if Node == node_head
			node_head = Successor
		else if Node == node_leftest
			node_leftest = node_head.find_leftest()
		else if Node == node_rightest
			node_rightest = node_head.find_rightest()
		inner_size--
		delete Node
	}

	///@function 
	static underlying_location = function(Value) {
		if 0 == inner_size
			return undefined

		var Node = node_head, CompVal
		while !is_undefined(Node) {
			CompVal = extract_key(Node)
			if Value == CompVal {
				return Node
			} else {
				if key_inquire_comparator(Value, CompVal)
					Node = Node.node_left
				else
					Node = Node.node_right
			}
		}
		return undefined
	}

	node_rightest = undefined
	key_inquire_comparator = compare_less
	key_comparator = function(a, b) {
		var A = extract_key(a), B = extract_key(b)
		if A == B
			return b < a
		else
			return key_inquire_comparator(A, B)
	}
#endregion

	// ** Contructor **
	if 0 < argument_count {
		if argument_count == 1 {
			var Item = argument[0]
			if is_array(Item) {
				// (*) Built-in Array
				for (var i = 0; i < array_length(Item); ++i) insert(Item[i])
			} else if !is_nan(Item) and ds_exists(Item, ds_type_list) {
				// (*) Built-in List
				for (var i = 0; i < inner_size; ++i) insert(Item[| i])
			} else if is_struct(Item) and is_iterable(Item) {
				// (*) Container
				foreach(Item.first(), Item.last(), insert)
			} else {
				// (*) Arg
				insert(Item)
			}
		} else {
			// (*) Iterator-Begin, Iterator-End
			if argument_count == 2 {
				if is_struct(argument[0]) and is_iterator(argument[0])
				and is_struct(argument[1]) and is_iterator(argument[1]) {
					foreach(argument[0], argument[1], insert)
					exit
				}
			}
			// (*) Arg0, Arg1, ...
			for (var i = 0; i < argument_count; ++i) insert(argument[i])
		}
	}
}

