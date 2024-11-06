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
  public :: vk_get_instance_proc_addr
  public :: vk_enumerate_physical_devices

  public :: forvulkan_create_debug_utils_messenger_ext
  public :: forvulkan_destroy_debug_utils_messenger_ext

  !* Types.

  public :: vk_extension_properties
  public :: vk_application_info
  public :: vk_instance_create_info
  public :: vk_layer_properties
  public :: vk_debug_utils_label_ext
  public :: vk_debug_utils_object_name_info_ext
  public :: vk_debug_utils_messenger_callback_data_ext
  public :: vk_debug_utils_messenger_create_info_ext


!* TYPES. ============================c===================================

  !! NOTE: !!
  !! typedef uint32_t VkFlags; !!
  !! vk_flags VkFlags is of type integer(c_int32_t) !!


  type, bind(c) :: vk_extension_properties
    character(len = 1, kind = c_char), dimension(VK_MAX_EXTENSION_NAME_SIZE) :: extension_name
    ! uint32_t
    integer(c_int32_t) :: spec_version = 0
  end type vk_extension_properties


  type, bind(c) :: vk_application_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! void *
    type(c_ptr) :: p_next = c_null_ptr
    ! char *
    type(c_ptr) :: p_application_name = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: application_version = 0
    ! char *
    type(c_ptr) :: p_engine_name = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: engine_version = 0
    ! uint32_t
    integer(c_int32_t) :: api_version = 0
  end type vk_application_info


  type, bind(c) :: vk_instance_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t [VkInstanceCreateFlags]
    integer(c_int32_t) :: flags = 0
    ! const VkApplicationInfo *
    type(c_ptr) :: p_application_info = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: enabled_layer_count = 0
    ! const char *
    type(c_ptr) :: pp_enabled_layer_names = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: enabled_extension_count = 0
    ! const char * const *  aka: (string array)
    type(c_ptr) :: pp_enabled_extension_names = c_null_ptr
  end type vk_instance_create_info


  type, bind(c) :: vk_layer_properties
    character(len = 1, kind = c_char), dimension(VK_MAX_EXTENSION_NAME_SIZE) :: layer_name
    ! uint32_t
    integer(c_int32_t) :: spec_version = 0
    ! uint32_t
    integer(c_int32_t) :: implementation_version = 0
    character(len = 1, kind = c_char), dimension(VK_MAX_DESCRIPTION_SIZE) :: description
  end type vk_layer_properties


  type, bind(c) :: vk_debug_utils_label_ext
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! const char *
    type(c_ptr) :: p_label_name = c_null_ptr
    real(c_float), dimension(4) :: color
  end type vk_debug_utils_label_ext


  type, bind(c) :: vk_debug_utils_object_name_info_ext
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t [VkObjectType]
    integer(c_int32_t) :: object_type = 0
    ! uint64_t
    integer(c_int64_t) :: object_handle = 0
    ! const char *
    type(c_ptr) :: p_object_name = c_null_ptr
  end type vk_debug_utils_object_name_info_ext


  type, bind(c) :: vk_debug_utils_messenger_callback_data_ext
    ! int32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t [VkDebugUtilsMessengerCallbackDataFlagsEXT]
    integer(c_int32_t) :: flags = 0
    ! const char *
    type(c_ptr) :: p_message_id_name = c_null_ptr
    ! int32_t
    integer(c_int32_t) :: message_id_number = 0
    ! const char *
    type(c_ptr) :: p_message = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: queue_label_count = 0
    ! const VkDebugUtilsLabelEXT *
    type(c_ptr) :: p_queue_labels = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: cmd_buf_label_count = 0
    ! const VkDebugUtilsLabelEXT *
    type(c_ptr) :: p_cmd_buf_labels = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: object_count = 0
    ! const VkDebugUtilsObjectNameInfoEXT *
    type(c_ptr) :: p_objects = c_null_ptr
  end type vk_debug_utils_messenger_callback_data_ext


  type, bind(c) :: vk_debug_utils_messenger_create_info_ext
    ! int32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t [VkDebugUtilsMessengerCreateFlagsEXT]
    integer(c_int32_t) :: flags = 0
    ! uint32_t [VkDebugUtilsMessageSeverityFlagsEXT]
    integer(c_int32_t) :: message_severity = 0
    ! uint32_t [VkDebugUtilsMessageTypeFlagsEXT]
    integer(c_int32_t) :: message_type = 0
    ! PFN_vkDebugUtilsMessengerCallbackEXT
    type(c_funptr) :: pfn_user_callback = c_null_funptr
    ! void *
    type(c_ptr) :: p_user_data = c_null_ptr
  end type vk_debug_utils_messenger_create_info_ext


!* C FUNCTION INTERFACES. ===============================================================


  interface


    function vk_create_instance(p_create_info, p_allocator, p_instance) result(res) bind(c, name = "vkCreateInstance")
      use, intrinsic :: iso_c_binding
      implicit none

      ! const VkInstanceCreateInfo *, const VkAllocationCallbacks *, VkInstance *
      type(c_ptr), intent(in), value :: p_create_info, p_allocator
      integer(c_int64_t), intent(inout) :: p_instance
      integer(c_int32_t) :: res
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
      integer(c_int32_t), intent(inout) :: p_property_count
      ! VkResult.
      integer(c_int32_t) :: vk_result
    end function vk_enumerate_instance_extension_properties


    function vk_enumerate_instance_layer_properties(p_property_count, p_properties) result (vk_result) bind(c, name = "vkEnumerateInstanceLayerProperties")
      use, intrinsic :: iso_c_binding
      implicit none

      ! uint32 *
      integer(c_int32_t), intent(inout) :: p_property_count
      ! VkLayerProperties *
      type(c_ptr), intent(in), value :: p_properties
      ! VkResult
      integer(c_int32_t) :: vk_result
    end function vk_enumerate_instance_layer_properties


    !* Note: This is for getting Vulkan function pointers.
    function vk_get_instance_proc_addr(instance, p_name) result(pfn_vk_void_function) bind(c, name = "vkGetInstanceProcAddr")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkInstance
      integer(c_int64_t), intent(in), value :: instance
      ! const char *
      type(c_ptr), intent(in), value :: p_name
      type(c_funptr) :: pfn_vk_void_function
    end function vk_get_instance_proc_addr


    function vk_enumerate_physical_devices(instance, p_physical_device_count, p_physical_devices) result(vk_result) bind(c, name = "vkEnumeratePhysicalDevices")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkInstance
      integer(c_int64_t), intent(in), value :: instance
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_physical_device_count
      ! VkPhysicalDevice *
      type(c_ptr), intent(in), value :: p_physical_devices
      integer(c_int32_t) :: vk_result
    end function vk_enumerate_physical_devices


!? FUNCTION BLUEPRINTS. ============================================================


    function pfn_vk_create_debug_utils_messenger_ext(instance, p_create_info, p_allocator, p_messenger) result(vk_result) bind(c)
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkInstance
      integer(c_int64_t), intent(in), value :: instance
      ! const VkDebugUtilsMessengerCreateInfoEXT*
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_funptr), intent(in), value :: p_allocator
      ! VkDebugUtilsMessengerEXT *
      integer(c_int64_t), intent(inout) :: p_messenger
      integer(c_int32_t) :: vk_result
    end function pfn_vk_create_debug_utils_messenger_ext


    subroutine pfn_vk_destroy_debug_utils_messenger_ext(instance, messenger, p_allocator) bind(c)
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkInstance
      integer(c_int64_t), intent(in), value :: instance
      ! VkDebugUtilsMessengerEXT
      integer(c_int64_t), intent(in), value :: messenger
      ! const VkAllocationCallbacks *
      type(c_funptr), intent(in), value :: p_allocator
    end subroutine pfn_vk_destroy_debug_utils_messenger_ext


  end interface


contains


  function vk_make_api_version(variant, major, minor, patch) result(version)
    implicit none

    integer(c_int32_t), intent(in), value :: variant, major, minor, patch
    integer(c_int32_t) :: version

    version = or(or(or(lshift(variant, 29), lshift(major, 22)), lshift(minor, 12)), patch)
  end function vk_make_api_version


  function forvulkan_create_debug_utils_messenger_ext(instance, p_create_info, p_allocator, p_debug_messenger) result(vk_result)
    implicit none

    integer(c_int64_t), intent(in), value :: instance
    ! const VkDebugUtilsMessengerCreateInfoEXT *
    type(c_ptr), intent(in), value :: p_create_info
    ! const VkAllocationCallbacks *
    type(c_funptr), intent(in), value :: p_allocator
    ! VkDebugUtilsMessengerEXT *
    integer(c_int64_t), intent(inout) :: p_debug_messenger
    integer(c_int32_t) :: vk_result
    character(len = :, kind = c_char), pointer :: function_name
    type(c_funptr) :: function_pointer
    procedure(pfn_vk_create_debug_utils_messenger_ext), pointer :: func

    ! We're asking Vulkan for the function pointer for debug info here.
    allocate(character(len = 31, kind = c_char) :: function_name)
    function_name = "vkCreateDebugUtilsMessengerEXT"//achar(0)

    function_pointer = vk_get_instance_proc_addr(instance, c_loc(function_name))

    ! If it's not available, we cannot continue in debug mode.
    if (.not. c_associated(function_pointer)) then
      vk_result = VK_ERROR_EXTENSION_NOT_PRESENT
      return
    end if

    ! Now we're transfering the function from C to Fortran.
    call c_f_procpointer(function_pointer, func)

    ! And we run it. :)
    vk_result = func(instance, p_create_info, p_allocator, p_debug_messenger)
  end function forvulkan_create_debug_utils_messenger_ext


  subroutine forvulkan_destroy_debug_utils_messenger_ext(instance, debug_messenger, p_allocator)
    implicit none

    integer(c_int64_t), intent(in), value :: instance
    ! VkDebugUtilsMessengerEXT
    integer(c_int64_t), intent(in), value :: debug_messenger
    ! const VkAllocationCallbacks *
    type(c_funptr), intent(in), value :: p_allocator
    character(len = :, kind = c_char), pointer :: function_name
    type(c_funptr) :: function_pointer
    procedure(pfn_vk_destroy_debug_utils_messenger_ext), pointer :: func

    ! We're asking Vulkan for the function pointer for debug info here.
    allocate(character(len = 32, kind = c_char) :: function_name)
    function_name = "vkDestroyDebugUtilsMessengerEXT"//achar(0)

    function_pointer = vk_get_instance_proc_addr(instance, c_loc(function_name))

    ! If it's not available, we cannot continue in debug mode.
    if (.not. c_associated(function_pointer)) then
      print"(A)","[Vulkan] WARNING: Failed to destroy debug messenger."
      return
    end if

    ! Transfer the function from C to Fortran.
    call c_f_procpointer(function_pointer, func)

    ! And we run it. :D
    call func(instance, debug_messenger, p_allocator)
  end subroutine forvulkan_destroy_debug_utils_messenger_ext


end module forvk
