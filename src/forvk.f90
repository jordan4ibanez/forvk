module forvk
  use, intrinsic :: iso_c_binding
  use :: forvk_parameters
  implicit none

  ! https://github.com/KhronosGroup/Vulkan-Headers/blob/main/include/vulkan/vulkan_core.h

  private


  !* Functions.

  public :: vk_enumerate_instance_extension_properties
  public :: vk_enumerate_instance_layer_properties
  public :: vk_make_api_version
  public :: vk_create_instance
  public :: vk_destroy_instance


  !* Types.

  public :: vk_extension_properties
  public :: vk_application_info
  public :: vk_instance_create_info
  public :: vk_layer_properties



!* TYPES. ============================c===================================

  !! NOTE: !!
  !! typedef uint32_t VkFlags; !!
  !! vk_flags VkFlags is of type integer(c_int) !!


  type, bind(c) :: vk_extension_properties
    character(len = 1, kind = c_char), dimension(VK_MAX_EXTENSION_NAME_SIZE) :: extension_name
    ! uint32_t
    integer(c_int32_t) :: spec_version
  end type vk_extension_properties


  type, bind(c) :: vk_application_info
    ! uint32_t [VkStructureType]
    integer(c_int) :: s_type
    ! void *
    type(c_ptr) :: p_next
    ! char *
    type(c_ptr) :: p_application_name
    ! uint32_t
    integer(c_int) :: application_version
    ! char *
    type(c_ptr) :: p_engine_name
    ! uint32_t
    integer(c_int) :: engine_version
    ! uint32_t
    integer(c_int) :: api_version
  end type vk_application_info


  type, bind(c) :: vk_instance_create_info
    ! uint32_t [VkStructureType]
    integer(c_int) :: s_type
    ! void *
    type(c_ptr) :: p_next
    ! uint32_t [VkInstanceCreateFlags]
    integer(c_int) :: flags
    ! const VkApplicationInfo *
    type(c_ptr) :: p_application_info
    ! uint32_t
    integer(c_int) :: enabled_layer_count
    ! const char *
    type(c_ptr) :: pp_enabled_layer_names
    ! uint32_t
    integer(c_int) :: enabled_extension_count
    ! const char * const *  aka: (string array)
    type(c_ptr) :: pp_enabled_extension_names
  end type vk_instance_create_info


  type, bind(c) :: vk_layer_properties
    character(len = 1, kind = c_char), dimension(VK_MAX_EXTENSION_NAME_SIZE) :: layer_name
    ! uint32_t
    integer(c_int32_t) :: spec_version
    ! uint32_t
    integer(c_int32_t) :: implementation_version
    character(len = 1, kind = c_char), dimension(VK_MAX_DESCRIPTION_SIZE) :: description
  end type vk_layer_properties


  type, bind(c) :: vk_debug_utils_label_ext
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type
    ! const void *
    type(c_ptr) :: p_next
    ! const char *
    type(c_ptr) :: p_label_name
    real(c_float), dimension(4) :: color
  end type vk_debug_utils_label_ext


  type, bind(c) :: vk_debug_utils_object_name_info_ext
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type
    ! void *
    type(c_ptr) :: p_next
    ! uint32_t [VkObjectType]
    integer(c_int32_t) :: object_type
    ! uint64_t
    integer(c_int64_t) :: object_handle
    ! const char *
    type(c_ptr) :: p_object_name
  end type vk_debug_utils_object_name_info_ext
!* C FUNCTION INTERFACES. ===============================================================


  interface


    function vk_create_instance(p_create_info, p_allocator, p_instance) result(res) bind(c, name = "vkCreateInstance")
      use, intrinsic :: iso_c_binding
      implicit none

      ! const VkInstanceCreateInfo *, const VkAllocationCallbacks *, VkInstance *
      type(c_ptr), intent(in), value :: p_create_info, p_allocator
      integer(c_int64_t), intent(inout) :: p_instance
      integer(c_int) :: res
    end function vk_create_instance


    subroutine vk_destroy_instance(instance, p_allocator) bind(c, name = "vkDestroyInstance")
      use, intrinsic :: iso_c_binding
      implicit none

      integer(c_int64_t), intent(in), value :: instance
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_instance


    function vk_enumerate_instance_extension_properties(p_layer_name, p_property_count, p_properties) result(vk_result) bind(c, name = "vkEnumerateInstanceExtensionProperties")
      use, intrinsic :: iso_c_binding
      implicit none

      ! char*, uint32_t*, VkExtensionProperties*
      type(c_ptr), intent(in), value :: p_layer_name, p_properties
      integer(c_int), intent(inout) :: p_property_count
      ! VkResult.
      integer(c_int) :: vk_result
    end function vk_enumerate_instance_extension_properties


    function vk_enumerate_instance_layer_properties(p_property_count, p_properties) result (vk_result) bind(c, name = "vkEnumerateInstanceLayerProperties")
      use, intrinsic :: iso_c_binding
      implicit none

      ! uint32 *
      integer(c_int), intent(inout) :: p_property_count
      ! VkLayerProperties *
      type(c_ptr), intent(in), value :: p_properties
      ! VkResult
      integer(c_int) :: vk_result
    end function vk_enumerate_instance_layer_properties



  end interface


contains


  function vk_make_api_version(variant, major, minor, patch) result(ver)
    implicit none

    integer(c_int), intent(in), value :: variant, major, minor, patch
    integer(c_int) :: ver

    ver = xor(xor(xor(lshift(variant, 29), lshift(major, 22)), lshift(minor, 12)), patch)

  end function vk_make_api_version


end module forvk
