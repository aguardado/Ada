-- Alba Guardado Garcia

with Ada.Text_IO;
with Maps_G;
with Ada.Calendar;
with Lower_Layer_UDP; 
with Seq_N_T;
with Calendar_Image;
with Maps_Protector_G;
with Ada.Strings.Unbounded;
with Image_EP;
--P5
with Ordered_Maps_G;
with Others_P5;
with Ordered_Maps_Protector_G;
with Chat_Messages;

package Handler is 

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package Seq renames Seq_N_T;
	package C_Image renames Calendar_Image;
	package Othrs renames Others_P5;
	package CM renames Chat_Messages;
	
	
	
	-- instancio mi maps_g
	
	package NP_Neighbors is new Maps_G (Key_Type => LLU.End_Point_Type,
													Value_Type => Ada.Calendar.Time,
													Null_Key => null,
													Null_Value => Ada.Calendar.Time_Of(1970,1,1,0.0), 
													Max_Length => 10,
													"=" => LLU."=",
													Key_To_String  => Image_EP.Image,
													Value_To_String  => C_Image.Image_1);
										
	package NP_Latest_Msgs is new Maps_G (	Key_Type => LLU.End_Point_Type,
														Value_Type => Seq.Seq_N_T,
														Null_Key => null,
														Null_Value => 0, 
														Max_Length => 50,
														"=" => LLU."=",
														Key_To_String  => Image_EP.Image,
														Value_To_String  => Seq.Seq_N_T'Image);
								
	
	package Neighbor is new Maps_Protector_G (NP_Neighbors);
	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);
	
	My_Neighs: Neighbor.Prot_Map; -- esta es mi lista de neighbors
	My_Msgs: Latest_Msgs.Prot_Map; -- esta es mi lista de ultimos mensajes
	
	EP_H: LLU.End_Point_Type;
	Nick_Usuario: ASU.Unbounded_String;
	
	-- Neighbor.Put (My_Neighs, EP, Clock, Success);
	-- Latest_Msgs.Put (My_Msgs, EP, Clock, Success);
	
	
	-- instancio mi ordered_maps_g
	package NP_Sender_Dests is new Ordered_Maps_G ( Key_Type => Othrs.Mess_Id_T, 
																	Value_Type => Othrs.Destinations_T,
																	"=" => Othrs."=",
																	"<" => Othrs."<",
																	">" => Othrs.">",
																	Key_To_String => Othrs.Mess_Id_T_To_String,
																	Value_To_String => Othrs.Destinations_T_To_String);
	
	
	
	package NP_Sender_Buffering is new Ordered_Maps_G (Key_Type => Ada.Calendar.Time, 
																		Value_Type => Othrs.Value_T,
																		"=" => Ada.Calendar."=",
																		"<" => Ada.Calendar."<",
																		">" => Ada.Calendar.">",
																		Key_To_String => C_Image.Image_1,
																		Value_To_String => Othrs.Value_T_To_String);

	
	package Sender_Dests is new Ordered_Maps_Protector_G (NP_Sender_Dests);
	package Sender_Buffering is new Ordered_Maps_Protector_G (NP_Sender_Buffering);
	
	My_SB_Map: Sender_Buffering.Prot_Map;
	My_SD_Map: Sender_Dests.Prot_Map;
	
	
	-- Declaro mis procedimientos
	procedure Put_Sender_Buffering (	P_Buffer: CM.Buffer_A_T;  Plazo_Retransmision: in out Duration; 
												Hora_Retransmision: in out Ada.Calendar.Time; EP_H_Creat: LLU.End_Point_Type;
												Seq_N: in out Seq.Seq_N_T);
	

	procedure Put_Sender_Dests (Key_Sender_Dests: in out Othrs.Mess_Id_T ; Value_Sender_Dests: in out Othrs.Destinations_T;
										EP_H_Creat: LLU.End_Point_Type; Seq_N: in out Seq.Seq_N_T);
	
	procedure Retransmisiones (Hora_Retransmision: in  Ada.Calendar.Time);
	
	procedure Client_Handler (	From: in LLU.End_Point_Type;
										To: in LLU.End_Point_Type;
										P_Buffer: access LLU.Buffer_Type);
	

end Handler;

