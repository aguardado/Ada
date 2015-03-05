-- Alba Guardado Garcia

--
--  TAD genérico de una tabla de símbolos (map) implementada como una lista
--  enlazada no ordenada.
--

generic
   type Key_Type is private;
   type Value_Type is private;
   with function "=" (K1, K2: Key_Type) return Boolean;
   with function "<" (K1, K2: Key_Type) return Boolean;
   with function ">" (K1, K2: Key_Type) return Boolean;
   with function Key_To_String (K: Key_Type) return String;
   with function Value_To_String (K: Value_Type) return String;
package Ordered_Maps_G is

   type Map is limited private;
   
   
	-- Dada una key, devuelve el value asociado a la misma en caso de que ese elemento exista
   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean);

	-- Dado un nuevo elemento (key, value) se añade a la tabla. 
	-- Si la key ya existia se remplaza la value nueva
	-- Cuando no se ha podido añadir un nuevo elemento a la tabla por el Max_Length => Succes:= True;
   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type);

	-- Dada una key, se borra de la tabla la key y el value asociado a dicha key
   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean);


   function Map_Length (M : Map) return Natural;

   procedure Print_Map (M : Map);


private

   type Tree_Node;
   type Map is access Tree_Node;
   type Tree_Node is record
      Key   : Key_Type;
      Value : Value_Type;
      Left  : Map;
      Right : Map;
   end record;

end Ordered_Maps_G;
