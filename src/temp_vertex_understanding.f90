module temp_vertex_understanding
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector_3f
  use :: vector_2f
  implicit none



  type :: vertex
    type(vec2f) :: position
    type(vec3f) :: color
  contains
    procedure, nopass :: get_binding_description => vertex_get_binding_description
  end type vertex


contains


  function vertex_get_binding_description() result(binding_description)
    implicit none

    type(vk_vertex_input_binding_description) :: binding_description

    binding_description%binding = 0
    binding_description%stride = sizeof(vertex())
    binding_description%input_rate = VK_VERTEX_INPUT_RATE_VERTEX
  end function vertex_get_binding_description


end module temp_vertex_understanding
