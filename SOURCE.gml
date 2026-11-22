/*
	GMStructor

	This extension allows you to create instances of objects like constructor functions ( using the custom operator 'new_GMS' )
	In addition, the game will now check the existence of the 'App' object at startup and initiate the creation of its instance, 
	which will serve as the entry point of your game ( all instances that will be created inside the Create event of this object will be 'persistent = true',
	including 'App' object instance itself )
	
	Copyright (c) 2026 Soykow

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

#region Public API

	#macro new_GMS global.__gms.	//	Macro-typed operator to create new object instance
									//	Template to use: 
									//
									//	var _instance = new_GMS OBJECT_NAME( );

#endregion
#region Init

	global.__gms = { };

	var _objects_number = 0;

	var _object_index = 0;
	var _object_name;
	
	var _loader_room = undefined;
	
	//	Begin infinity cycle
	while ( true )
	{
		///	@method
		///	@description Create new instance
		///	@return {Id.Instance}
		var _New = function( )
		{
			var _instance = instance_create_depth( 0, 0, 0, object );
			
			//	Object has 'Constructor' method
			//	Call this method
			if ( variable_instance_exists( _instance, "Constructor" ) )
			{
				var _parameters = [ ];
				var _parameter_index = 0;
				
				repeat ( argument_count ) array_push( _parameters, argument[ _parameter_index ++ ] );
				method_call( _instance.Constructor, _parameters );
			};
			
			return _instance;
		};
		
			_object_name = object_get_name( _object_index );

		//	Check service object name ( this is the end of object assets list )
		//	Final check
		if ( string_starts_with( _object_name, "__YYInternalObject__" ) )
		{
			//	There are missing objects
			//	Throw error
			if ( _objects_number < _object_index )
			{
				show_message( "GMStructor Error!\n\nDisable 'Automatically remove unused assets then compiling' first\nGame Options -> Main Options -> General" );
				game_end( 1 );
			};
			
			break;
		};
		
		//	Object exists
		//	Assign new constructor method
		if ( object_exists( _object_index ) )
		{
			//	Object named as 'App'
			//	Enable app auto-loader
			if ( _object_name == "App" )
			{
					_loader_room = room_add( );
								   room_instance_add( _loader_room, 0, 0, _object_index );				   
			}
			//	Default constructor method assign
			else
			{
				struct_set( global.__gms, _object_name, method( { object: _object_index }, _New ) );
			};
			
				_objects_number ++;
		};
			
			_object_index ++;
	};
	
	//	Loader room exists ( parser should create it )
	//	Go to loader room
	if ( room_exists( _loader_room ) )
	{
		room_goto( _loader_room );
		
		//	Waiting for the 1 frame 
		//	until room will be loaded
		call_later( 1, time_source_units_frames,
			///	@method
			///	@description Go back to default room order
			function( )
			{
				//	Reference to all instances
				//	Toggle persistent
				with ( all ) persistent = true;
				
				room_goto( room_first );
			} );
	};
	
#endregion
