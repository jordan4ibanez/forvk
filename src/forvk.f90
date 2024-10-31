module forvk
  use, intrinsic :: iso_c_binding
  implicit none


  private


  public :: vk_enumerate_instance_extension_properties


!* PARAMETERS. ===============================================================


  integer(c_int), parameter, public :: VK_MAX_EXTENSION_NAME_SIZE = 256

  !? VkResult.

  integer(c_int), parameter, public :: VK_SUCCESS = 0
  integer(c_int), parameter, public :: VK_NOT_READY = 1
  integer(c_int), parameter, public :: VK_TIMEOUT = 2
  integer(c_int), parameter, public :: VK_EVENT_SET = 3
  integer(c_int), parameter, public :: VK_EVENT_RESET = 4
  integer(c_int), parameter, public :: VK_INCOMPLETE = 5
  integer(c_int), parameter, public :: VK_ERROR_OUT_OF_HOST_MEMORY = -1
  integer(c_int), parameter, public :: VK_ERROR_OUT_OF_DEVICE_MEMORY = -2
  integer(c_int), parameter, public :: VK_ERROR_INITIALIZATION_FAILED = -3
  integer(c_int), parameter, public :: VK_ERROR_DEVICE_LOST = -4
  integer(c_int), parameter, public :: VK_ERROR_MEMORY_MAP_FAILED = -5
  integer(c_int), parameter, public :: VK_ERROR_LAYER_NOT_PRESENT = -6
  integer(c_int), parameter, public :: VK_ERROR_EXTENSION_NOT_PRESENT = -7
  integer(c_int), parameter, public :: VK_ERROR_FEATURE_NOT_PRESENT = -8
  integer(c_int), parameter, public :: VK_ERROR_INCOMPATIBLE_DRIVER = -9
  integer(c_int), parameter, public :: VK_ERROR_TOO_MANY_OBJECTS = -10
  integer(c_int), parameter, public :: VK_ERROR_FORMAT_NOT_SUPPORTED = -11
  integer(c_int), parameter, public :: VK_ERROR_FRAGMENTED_POOL = -12
  integer(c_int), parameter, public :: VK_ERROR_UNKNOWN = -13
  ! Provided by VK_VERSION_1_1
  integer(c_int), parameter, public :: VK_ERROR_OUT_OF_POOL_MEMORY = -1000069000
  ! Provided by VK_VERSION_1_1
  integer(c_int), parameter, public :: VK_ERROR_INVALID_EXTERNAL_HANDLE = -1000072003
  ! Provided by VK_VERSION_1_2
  integer(c_int), parameter, public :: VK_ERROR_FRAGMENTATION = -1000161000
  ! Provided by VK_VERSION_1_2
  integer(c_int), parameter, public :: VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS = -1000257000
  ! Provided by VK_VERSION_1_3
  integer(c_int), parameter, public :: VK_PIPELINE_COMPILE_REQUIRED = 1000297000
  ! Provided by VK_KHR_surface
  integer(c_int), parameter, public :: VK_ERROR_SURFACE_LOST_KHR = -1000000000
  ! Provided by VK_KHR_surface
  integer(c_int), parameter, public :: VK_ERROR_NATIVE_WINDOW_IN_USE_KHR = -1000000001
  ! Provided by VK_KHR_swapchain
  integer(c_int), parameter, public :: VK_SUBOPTIMAL_KHR = 1000001003
  ! Provided by VK_KHR_swapchain
  integer(c_int), parameter, public :: VK_ERROR_OUT_OF_DATE_KHR = -1000001004
  ! Provided by VK_KHR_display_swapchain
  integer(c_int), parameter, public :: VK_ERROR_INCOMPATIBLE_DISPLAY_KHR = -1000003001
  ! Provided by VK_EXT_debug_report
  integer(c_int), parameter, public :: VK_ERROR_VALIDATION_FAILED_EXT = -1000011001
  ! Provided by VK_NV_glsl_shader
  integer(c_int), parameter, public :: VK_ERROR_INVALID_SHADER_NV = -1000012000
  ! Provided by VK_KHR_video_queue
  integer(c_int), parameter, public :: VK_ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR = -1000023000
  ! Provided by VK_KHR_video_queue
  integer(c_int), parameter, public :: VK_ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR = -1000023001
  ! Provided by VK_KHR_video_queue
  integer(c_int), parameter, public :: VK_ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR = -1000023002
  ! Provided by VK_KHR_video_queue
  integer(c_int), parameter, public :: VK_ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR = -1000023003
  ! Provided by VK_KHR_video_queue
  integer(c_int), parameter, public :: VK_ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR = -1000023004
  ! Provided by VK_KHR_video_queue
  integer(c_int), parameter, public :: VK_ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR = -1000023005
  ! Provided by VK_EXT_image_drm_format_modifier
  integer(c_int), parameter, public :: VK_ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT = -1000158000
  ! Provided by VK_KHR_global_priority
  integer(c_int), parameter, public :: VK_ERROR_NOT_PERMITTED_KHR = -1000174001
  ! Provided by VK_EXT_full_screen_exclusive
  integer(c_int), parameter, public :: VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT = -1000255000
  ! Provided by VK_KHR_deferred_host_operations
  integer(c_int), parameter, public :: VK_THREAD_IDLE_KHR = 1000268000
  ! Provided by VK_KHR_deferred_host_operations
  integer(c_int), parameter, public :: VK_THREAD_DONE_KHR = 1000268001
  ! Provided by VK_KHR_deferred_host_operations
  integer(c_int), parameter, public :: VK_OPERATION_DEFERRED_KHR = 1000268002
  ! Provided by VK_KHR_deferred_host_operations
  integer(c_int), parameter, public :: VK_OPERATION_NOT_DEFERRED_KHR = 1000268003
  ! Provided by VK_KHR_video_encode_queue
  integer(c_int), parameter, public :: VK_ERROR_INVALID_VIDEO_STD_PARAMETERS_KHR = -1000299000
  ! Provided by VK_EXT_image_compression_control
  integer(c_int), parameter, public :: VK_ERROR_COMPRESSION_EXHAUSTED_EXT = -1000338000
  ! Provided by VK_EXT_shader_object
  integer(c_int), parameter, public :: VK_INCOMPATIBLE_SHADER_BINARY_EXT = 1000482000
  ! Provided by VK_KHR_pipeline_binary
  integer(c_int), parameter, public :: VK_PIPELINE_BINARY_MISSING_KHR = 1000483000
  ! Provided by VK_KHR_pipeline_binary
  integer(c_int), parameter, public :: VK_ERROR_NOT_ENOUGH_SPACE_KHR = -1000483000
  ! Provided by VK_KHR_maintenance1
  integer(c_int), parameter, public :: VK_ERROR_OUT_OF_POOL_MEMORY_KHR = VK_ERROR_OUT_OF_POOL_MEMORY
  ! Provided by VK_KHR_external_memory
  integer(c_int), parameter, public :: VK_ERROR_INVALID_EXTERNAL_HANDLE_KHR = VK_ERROR_INVALID_EXTERNAL_HANDLE
  ! Provided by VK_EXT_descriptor_indexing
  integer(c_int), parameter, public :: VK_ERROR_FRAGMENTATION_EXT = VK_ERROR_FRAGMENTATION
  ! Provided by VK_EXT_global_priority
  integer(c_int), parameter, public :: VK_ERROR_NOT_PERMITTED_EXT = VK_ERROR_NOT_PERMITTED_KHR
  ! Provided by VK_EXT_buffer_device_address
  integer(c_int), parameter, public :: VK_ERROR_INVALID_DEVICE_ADDRESS_EXT = VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS
  ! Provided by VK_KHR_buffer_device_address
  integer(c_int), parameter, public :: VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS_KHR = VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS
  ! Provided by VK_EXT_pipeline_creation_cache_control
  integer(c_int), parameter, public :: VK_PIPELINE_COMPILE_REQUIRED_EXT = VK_PIPELINE_COMPILE_REQUIRED
  ! Provided by VK_EXT_pipeline_creation_cache_control
  integer(c_int), parameter, public :: VK_ERROR_PIPELINE_COMPILE_REQUIRED_EXT = VK_PIPELINE_COMPILE_REQUIRED
  ! Provided by VK_EXT_shader_object
  ! VK_ERROR_INCOMPATIBLE_SHADER_BINARY_EXT is a deprecated alias
  integer(c_int), parameter, public :: VK_ERROR_INCOMPATIBLE_SHADER_BINARY_EXT = VK_INCOMPATIBLE_SHADER_BINARY_EXT


  !? VkStructureType
  ! todo: this lol


!* TYPES. ===============================================================


  type, bind(c) :: vk_extension_properties
    character(len = 1, kind = c_char), dimension(VK_MAX_EXTENSION_NAME_SIZE) :: extension_name
    !! was uint32_t
    integer(c_int32_t) :: spec_version
  end type vk_extension_properties


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
