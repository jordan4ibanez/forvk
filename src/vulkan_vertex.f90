module vulkan_vertex
  use, intrinsic :: iso_c_binding
  use :: forvulkan
  use :: vector_3f
  use :: vector_2f
  implicit none


  ! Vertex data is interleaved.
  type :: vertex
    type(vec2f) :: position
    type(vec3f) :: color
    type(vec2f) :: texture_coordinate
  end type vertex


contains


  function vertex_get_binding_description() result(binding_description)
    implicit none

    type(vk_vertex_input_binding_description) :: binding_description

    binding_description%binding = 0
    binding_description%stride = sizeof(vertex())
    binding_description%input_rate = VK_VERTEX_INPUT_RATE_VERTEX
  end function vertex_get_binding_description


  function vertex_get_attribute_descriptions() result(attribute_descriptions)
    implicit none

    type(vk_vertex_input_attribute_description), dimension(3) :: attribute_descriptions

    ! There is no offsetof in gfortran (yet) so we will have to calculate offset ourselves. :D
    ! You can use fpm to make a small project and recalculate this with sizeof() and break your struct down.

    !? Element 1.
    attribute_descriptions(1)%binding = 0
    attribute_descriptions(1)%location = 0
    attribute_descriptions(1)%format = vk_format(VK_FORMAT_R32G32_SFLOAT)
    ! 0 bytes = starting point.
    attribute_descriptions(1)%offset = 0

    !? Element 2.
    attribute_descriptions(2)%binding = 0
    attribute_descriptions(2)%location = 1
    attribute_descriptions(2)%format = vk_format(VK_FORMAT_R32G32B32_SFLOAT)
    ! vec2 elements * 4 byte float = 8 bytes
    attribute_descriptions(2)%offset = 8

    attribute_descriptions(3)%binding = 0
    attribute_descriptions(3)%location = 2
    attribute_descriptions(3)%format = vk_format(VK_FORMAT_R32G32_SFLOAT)
    ! 8 bytes + 12 bytes = 16 bytes
    attribute_descriptions(3)%offset = 16
  end function


end module vulkan_vertex
