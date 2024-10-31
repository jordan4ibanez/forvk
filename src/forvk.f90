module forvk
  use, intrinsic :: iso_c_binding
  implicit none


  private

  
  integer(c_int), parameter, public :: VK_MAX_EXTENSION_NAME_SIZE = 256


  type, bind(c) :: vk_extension_properties
    character(len = 1, kind = c_char), dimension(VK_MAX_EXTENSION_NAME_SIZE) :: extension_name
    !! was uint32_t
    integer(c_int32_t) :: spec_version
  end type vk_extension_properties


contains


end module forvk
