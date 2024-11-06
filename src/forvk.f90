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


  type, bind(c) :: vk_physical_device_limits
    ! uint32_t
    integer(c_int32_t) :: max_image_dimension_1d
    ! uint32_t
    integer(c_int32_t) :: max_image_dimension_2d
    ! uint32_t
    integer(c_int32_t) :: max_image_dimension_3d
    ! uint32_t
    integer(c_int32_t) :: max_image_dimension_cube
    ! uint32_t
    integer(c_int32_t) :: max_image_array_layers
    ! uint32_t
    integer(c_int32_t) :: max_texel_buffer_elements
    ! uint32_t
    integer(c_int32_t) :: max_uniform_buffer_range
    ! uint32_t
    integer(c_int32_t) :: max_storage_buffer_range
    ! uint32_t
    integer(c_int32_t) :: max_push_constants_size
    ! uint32_t
    integer(c_int32_t) :: max_memory_allocation_count
    ! uint32_t
    integer(c_int32_t) :: max_sampler_allocation_count
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: buffer_image_granularity
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: sparse_address_space_size
    ! uint32_t
    integer(c_int32_t) :: max_bound_descriptor_sets
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_samplers
    ! uint32_t
    integer(c_int32_t) ::  max_per_stage_descriptor_uniform_buffers
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_storage_buffers
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_sampled_images
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_storage_images
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_input_attachments
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_resources
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_samplers
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_uniform_buffers
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_uniform_buffers_dynamic
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_storage_buffers
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_storage_buffers_dynamic
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_sampled_images
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_storage_images
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_input_attachments
    ! uint32_t
    integer(c_int32_t) :: max_vertex_input_attributes
    ! uint32_t
    integer(c_int32_t) :: max_vertex_input_bindings
    ! uint32_t
    integer(c_int32_t) :: max_vertex_input_attribute_offset
    ! uint32_t
    integer(c_int32_t) :: max_vertex_input_binding_stride
    ! uint32_t
    integer(c_int32_t) :: max_vertex_output_components
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_generation_level
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_patch_size
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_control_per_vertex_input_components
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_control_per_vertex_output_components
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_control_per_patch_output_components
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_control_total_output_components
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_evaluation_input_components
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_evaluation_output_components
    ! uint32_t
    integer(c_int32_t) :: max_geometry_shader_invocations
    ! uint32_t
    integer(c_int32_t) :: max_geometry_input_components
    ! uint32_t
    integer(c_int32_t) :: max_geometry_output_components
    ! uint32_t
    integer(c_int32_t) :: max_geometry_output_vertices
    ! uint32_t
    integer(c_int32_t) :: max_geometry_total_output_components
    ! uint32_t
    integer(c_int32_t) :: max_fragment_input_components
    ! uint32_t
    integer(c_int32_t) :: max_fragment_output_attachments
    ! uint32_t
    integer(c_int32_t) :: max_fragment_dual_src_attachments
    ! uint32_t
    integer(c_int32_t) :: max_fragment_combined_output_resources
    ! uint32_t
    integer(c_int32_t) :: max_compute_shared_memory_size
    ! uint32_t[3]
    integer(c_int32_t), dimension(3) :: max_compute_work_group_count
    ! uint32_t
    integer(c_int32_t) :: max_compute_work_group_invocations
    ! uint32_t[3]
    integer(c_int32_t), dimension(3) :: max_compute_work_group_size
    ! uint32_t
    integer(c_int32_t) :: sub_pixel_precision_bits
    ! uint32_t
    integer(c_int32_t) :: sub_texel_precision_bits
    ! uint32_t
    integer(c_int32_t) :: mipmap_precision_bits
    ! uint32_t
    integer(c_int32_t) :: max_draw_indexed_index_value
    ! uint32_t
    integer(c_int32_t) :: max_draw_indirect_count
    ! float
    real(c_float) :: max_sampler_lod_bias
    ! float
    real(c_float) :: max_sampler_anisotropy
    ! uint32_t
    integer(c_int32_t) :: max_viewports
    ! uint32_t[2]
    integer(c_int32_t), dimension(2) :: max_viewport_dimensions
    ! uint32_t[2]
    integer(c_int32_t), dimension(2) :: viewport_bounds_range
    ! uint32_t
    integer(c_int32_t) :: viewport_sub_pixel_bits
    ! size_t
    integer(c_size_t) :: min_memory_map_alignment
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: min_texel_buffer_offset_alignment
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) ::  min_uniform_buffer_offset_alignment
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) ::  min_storage_buffer_offset_alignment
    ! int32_t
    integer(c_int32_t) :: min_texel_offset
    ! uint32_t
    integer(c_int32_t) ::  max_texel_offset
    ! int32_t
    integer(c_int32_t) ::  min_texel_gather_offset
    ! uint32_t
    integer(c_int32_t) :: max_texel_gather_offset
    ! float
    real(c_float) :: min_interpolation_offset
    ! float
    real(c_float) :: max_interpolation_offset
    ! uint32_t
    integer(c_int32_t) :: sub_pixel_interpolation_offset_bits
    ! uint32_t
    integer(c_int32_t) :: max_framebuffer_width
    ! uint32_t
    integer(c_int32_t) :: max_framebuffer_height
    ! uint32_t
    integer(c_int32_t) :: max_framebuffer_layers
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: framebuffer_color_sample_counts
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: framebuffer_depth_sample_counts
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: framebuffer_stencil_sample_counts
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: framebuffer_no_attachments_sample_counts
    ! uint32_t
    integer(c_int32_t) :: max_color_attachments
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: sampled_image_color_sample_counts
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: sampled_image_integer_sample_counts
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: sampled_image_depth_sample_counts
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: sampled_image_stencil_sample_counts
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: storage_image_sample_counts
    ! uint32_t
    integer(c_int32_t) :: max_sample_mask_words
    ! VkBool32
    integer(c_int32_t) :: timestamp_compute_and_graphics
    ! float
    real(c_float) :: timestamp_period
    ! uint32_t
    integer(c_int32_t) :: max_clip_distances
    ! uint32_t
    integer(c_int32_t) :: max_cull_distances
    ! uint32_t
    integer(c_int32_t) :: max_combined_clip_and_cull_distances
    ! uint32_t
    integer(c_int32_t) :: discrete_queue_priorities
    ! float[2]
    real(c_float), dimension(2) :: point_size_range
    ! float[2]
    real(c_float), dimension(2) :: line_width_range
    ! float
    real(c_float) :: point_size_granularity
    ! float
    real(c_float) :: line_width_granularity
    ! VkBool32
    integer(c_int32_t) :: strict_lines
    ! VkBool32
    integer(c_int32_t) :: standard_sample_locations
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: optimal_buffer_copy_offset_alignment
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: optimal_buffer_copy_row_pitch_alignment
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: non_coherent_atom_size
  end type vk_physical_device_limits


  type, bind(c) :: vk_physical_device_sparse_properties
    ! VkBool32
    integer(c_int32_t) :: residency_standard_2d_block_shape
    ! VkBool32
    integer(c_int32_t) :: residency_standard_2d_multisample_block_shape
    ! VkBool32
    integer(c_int32_t) :: residency_standard_3d_block_shape
    ! VkBool32
    integer(c_int32_t) :: residency_aligned_mip_size
    ! VkBool32
    integer(c_int32_t) :: residency_non_resident_strict
  end type vk_physical_device_sparse_properties
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
