module forvk
  use, intrinsic :: iso_c_binding
  use :: forvk_parameters
  implicit none


  private


  public :: vk_enumerate_instance_extension_properties





!* TYPES. ===============================================================


  type, bind(c) :: vk_extension_properties
    character(len = 1, kind = c_char), dimension(VK_MAX_EXTENSION_NAME_SIZE) :: extension_name
    !! was uint32_t
    integer(c_int32_t) :: spec_version
  end type vk_extension_properties


  type, bind(c) :: vk_application_info
    integer(c_int) :: s_type
    ! void *
    type(c_ptr) :: p_next
    ! char *
    type(c_ptr) :: p_application_name
    !! was uint32_t
    integer(c_int) :: application_version
    ! char *
    type(c_ptr) :: p_engine_name
    !! was uint32_t
    integer(c_int) :: engine_version
    !! was uint32_t
    integer(c_int) :: api_version
  end type vk_application_info


!* C FUNCTION INTERFACES. ===============================================================


  interface


    function vk_enumerate_instance_extension_properties(p_layer_name, p_property_count, p_properties) result(vk_result) bind(c, name = "vkEnumerateInstanceExtensionProperties")
      use, intrinsic :: iso_c_binding
      implicit none

      !? char*, uint32_t*, VkExtensionProperties*
      type(c_ptr), intent(in), value :: p_layer_name, p_property_count, p_properties
      !? VkResult.
      integer(c_int) :: vk_result
    end function vk_enumerate_instance_extension_properties



  end interface


contains


end module forvk
