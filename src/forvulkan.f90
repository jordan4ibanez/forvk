module forvulkan
  use, intrinsic :: iso_c_binding
  use :: forvulkan_parameters
  use :: vector
  implicit none


  ! https://github.com/KhronosGroup/Vulkan-Headers/blob/main/include/vulkan/vulkan_core.h
  ! Forvulkan is hand translated with love to ensure correctness. :D


!* TYPES. ============================c===================================

  !! NOTE: !!
  !! typedef uint32_t VkFlags !!
  !! vk_flags VkFlags is of type integer(c_int32_t) !!


  !? VkExtensionProperties.
  type, bind(c) :: vk_extension_properties
    character(len = 1, kind = c_char), dimension(VK_MAX_EXTENSION_NAME_SIZE) :: extension_name
    ! uint32_t
    integer(c_int32_t) :: spec_version = 0
  end type vk_extension_properties


  !? VkApplicationInfo.
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


  !? VkInstanceCreateInfo.
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


  !? VkLayerProperties.
  type, bind(c) :: vk_layer_properties
    character(len = 1, kind = c_char), dimension(VK_MAX_EXTENSION_NAME_SIZE) :: layer_name
    ! uint32_t
    integer(c_int32_t) :: spec_version = 0
    ! uint32_t
    integer(c_int32_t) :: implementation_version = 0
    character(len = 1, kind = c_char), dimension(VK_MAX_DESCRIPTION_SIZE) :: description
  end type vk_layer_properties


  !? VkDebugUtilsLabelExt.
  type, bind(c) :: vk_debug_utils_label_ext
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! const char *
    type(c_ptr) :: p_label_name = c_null_ptr
    real(c_float), dimension(4) :: color
  end type vk_debug_utils_label_ext


  !? VkDebugUtilsObjectNameInfoExt.
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


  !? VkDebugUtilsMessengerCallbackDataExt.
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


  !? VkDebugUtilsMessengerCreateInfoExt.
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


  !? VkPhysicalDeviceLimits.
  type, bind(c) :: vk_physical_device_limits
    ! uint32_t
    integer(c_int32_t) :: max_image_dimension_1d = 0
    ! uint32_t
    integer(c_int32_t) :: max_image_dimension_2d = 0
    ! uint32_t
    integer(c_int32_t) :: max_image_dimension_3d = 0
    ! uint32_t
    integer(c_int32_t) :: max_image_dimension_cube = 0
    ! uint32_t
    integer(c_int32_t) :: max_image_array_layers = 0
    ! uint32_t
    integer(c_int32_t) :: max_texel_buffer_elements = 0
    ! uint32_t
    integer(c_int32_t) :: max_uniform_buffer_range = 0
    ! uint32_t
    integer(c_int32_t) :: max_storage_buffer_range = 0
    ! uint32_t
    integer(c_int32_t) :: max_push_constants_size = 0
    ! uint32_t
    integer(c_int32_t) :: max_memory_allocation_count = 0
    ! uint32_t
    integer(c_int32_t) :: max_sampler_allocation_count = 0
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: buffer_image_granularity = 0
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: sparse_address_space_size = 0
    ! uint32_t
    integer(c_int32_t) :: max_bound_descriptor_sets = 0
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_samplers = 0
    ! uint32_t
    integer(c_int32_t) ::  max_per_stage_descriptor_uniform_buffers = 0
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_storage_buffers = 0
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_sampled_images = 0
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_storage_images = 0
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_descriptor_input_attachments = 0
    ! uint32_t
    integer(c_int32_t) :: max_per_stage_resources = 0
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_samplers = 0
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_uniform_buffers = 0
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_uniform_buffers_dynamic = 0
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_storage_buffers = 0
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_storage_buffers_dynamic = 0
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_sampled_images = 0
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_storage_images = 0
    ! uint32_t
    integer(c_int32_t) :: max_descriptor_set_input_attachments = 0
    ! uint32_t
    integer(c_int32_t) :: max_vertex_input_attributes = 0
    ! uint32_t
    integer(c_int32_t) :: max_vertex_input_bindings = 0
    ! uint32_t
    integer(c_int32_t) :: max_vertex_input_attribute_offset = 0
    ! uint32_t
    integer(c_int32_t) :: max_vertex_input_binding_stride = 0
    ! uint32_t
    integer(c_int32_t) :: max_vertex_output_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_generation_level = 0
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_patch_size = 0
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_control_per_vertex_input_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_control_per_vertex_output_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_control_per_patch_output_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_control_total_output_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_evaluation_input_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_tesselation_evaluation_output_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_geometry_shader_invocations = 0
    ! uint32_t
    integer(c_int32_t) :: max_geometry_input_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_geometry_output_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_geometry_output_vertices = 0
    ! uint32_t
    integer(c_int32_t) :: max_geometry_total_output_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_fragment_input_components = 0
    ! uint32_t
    integer(c_int32_t) :: max_fragment_output_attachments = 0
    ! uint32_t
    integer(c_int32_t) :: max_fragment_dual_src_attachments = 0
    ! uint32_t
    integer(c_int32_t) :: max_fragment_combined_output_resources = 0
    ! uint32_t
    integer(c_int32_t) :: max_compute_shared_memory_size = 0
    ! uint32_t[3]
    integer(c_int32_t), dimension(3) :: max_compute_work_group_count = 0
    ! uint32_t
    integer(c_int32_t) :: max_compute_work_group_invocations = 0
    ! uint32_t[3]
    integer(c_int32_t), dimension(3) :: max_compute_work_group_size = 0
    ! uint32_t
    integer(c_int32_t) :: sub_pixel_precision_bits = 0
    ! uint32_t
    integer(c_int32_t) :: sub_texel_precision_bits = 0
    ! uint32_t
    integer(c_int32_t) :: mipmap_precision_bits = 0
    ! uint32_t
    integer(c_int32_t) :: max_draw_indexed_index_value = 0
    ! uint32_t
    integer(c_int32_t) :: max_draw_indirect_count = 0
    ! float
    real(c_float) :: max_sampler_lod_bias = 0.0
    ! float
    real(c_float) :: max_sampler_anisotropy = 0.0
    ! uint32_t
    integer(c_int32_t) :: max_viewports = 0
    ! uint32_t[2]
    integer(c_int32_t), dimension(2) :: max_viewport_dimensions = 0
    ! uint32_t[2]
    integer(c_int32_t), dimension(2) :: viewport_bounds_range = 0
    ! uint32_t
    integer(c_int32_t) :: viewport_sub_pixel_bits = 0
    ! size_t
    integer(c_size_t) :: min_memory_map_alignment = 0
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: min_texel_buffer_offset_alignment = 0
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) ::  min_uniform_buffer_offset_alignment = 0
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) ::  min_storage_buffer_offset_alignment = 0
    ! int32_t
    integer(c_int32_t) :: min_texel_offset = 0
    ! uint32_t
    integer(c_int32_t) ::  max_texel_offset = 0
    ! int32_t
    integer(c_int32_t) ::  min_texel_gather_offset = 0
    ! uint32_t
    integer(c_int32_t) :: max_texel_gather_offset = 0
    ! float
    real(c_float) :: min_interpolation_offset = 0.0
    ! float
    real(c_float) :: max_interpolation_offset = 0.0
    ! uint32_t
    integer(c_int32_t) :: sub_pixel_interpolation_offset_bits = 0
    ! uint32_t
    integer(c_int32_t) :: max_framebuffer_width = 0
    ! uint32_t
    integer(c_int32_t) :: max_framebuffer_height = 0
    ! uint32_t
    integer(c_int32_t) :: max_framebuffer_layers = 0
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: framebuffer_color_sample_counts = 0
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: framebuffer_depth_sample_counts = 0
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: framebuffer_stencil_sample_counts = 0
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: framebuffer_no_attachments_sample_counts = 0
    ! uint32_t
    integer(c_int32_t) :: max_color_attachments = 0
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: sampled_image_color_sample_counts = 0
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: sampled_image_integer_sample_counts = 0
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: sampled_image_depth_sample_counts = 0
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: sampled_image_stencil_sample_counts = 0
    ! uint32_t [VkSampleCountFlags]
    integer(c_int32_t) :: storage_image_sample_counts = 0
    ! uint32_t
    integer(c_int32_t) :: max_sample_mask_words = 0
    ! VkBool32
    integer(c_int32_t) :: timestamp_compute_and_graphics = 0
    ! float
    real(c_float) :: timestamp_period = 0.0
    ! uint32_t
    integer(c_int32_t) :: max_clip_distances = 0
    ! uint32_t
    integer(c_int32_t) :: max_cull_distances = 0
    ! uint32_t
    integer(c_int32_t) :: max_combined_clip_and_cull_distances = 0
    ! uint32_t
    integer(c_int32_t) :: discrete_queue_priorities = 0
    ! float[2]
    real(c_float), dimension(2) :: point_size_range = 0.0
    ! float[2]
    real(c_float), dimension(2) :: line_width_range = 0.0
    ! float
    real(c_float) :: point_size_granularity = 0.0
    ! float
    real(c_float) :: line_width_granularity = 0.0
    ! VkBool32
    integer(c_int32_t) :: strict_lines = 0
    ! VkBool32
    integer(c_int32_t) :: standard_sample_locations = 0
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: optimal_buffer_copy_offset_alignment = 0
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: optimal_buffer_copy_row_pitch_alignment = 0
    ! uint64_t [VkDeviceSize]
    integer(c_int64_t) :: non_coherent_atom_size = 0
  end type vk_physical_device_limits


  !? VkPhysicalDeviceSparseProperties.
  type, bind(c) :: vk_physical_device_sparse_properties
    ! VkBool32
    integer(c_int32_t) :: residency_standard_2d_block_shape = 0
    ! VkBool32
    integer(c_int32_t) :: residency_standard_2d_multisample_block_shape = 0
    ! VkBool32
    integer(c_int32_t) :: residency_standard_3d_block_shape = 0
    ! VkBool32
    integer(c_int32_t) :: residency_aligned_mip_size = 0
    ! VkBool32
    integer(c_int32_t) :: residency_non_resident_strict = 0
  end type vk_physical_device_sparse_properties


  !? VkPhysicalDeviceProperties.
  type, bind(c) :: vk_physical_device_properties
    ! uint32_t
    integer(c_int32_t) :: api_version = 0
    ! uint32_t
    integer(c_int32_t) :: driver_version = 0
    ! uint32_t
    integer(c_int32_t) :: vendor_id = 0
    ! uint32_t
    integer(c_int32_t) :: device_id = 0
    ! VkPhysicalDeviceType. [uint32_t]
    integer(c_int32_t) :: device_type = 0
    character(len = 1, kind = c_char), dimension(VK_MAX_PHYSICAL_DEVICE_NAME_SIZE) :: device_name
    ! uint_8[VK_UUID_SIZE]
    integer(c_int8_t), dimension(VK_UUID_SIZE) :: pipeline_cache_uuid = 0
    ! VkPhysicalDeviceLimits
    type(vk_physical_device_limits) :: limits
    ! VkPhysicalDeviceSparseProperties
    type(vk_physical_device_sparse_properties) :: sparse_properties
  end type vk_physical_device_properties


  !? VkPhysicalDeviceFeatures.
  type, bind(c) :: vk_physical_device_features
    ! VkBool32
    integer(c_int32_t) :: robust_buffer_access = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: full_draw_index_uint32 = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: image_cube_array = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: independent_blend = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: geometry_shader = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: tesselation_shader = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sample_rate_shading = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: dual_src_blend = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: logic_op = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: multi_draw_indirect = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: draw_indirect_first_instance = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: depth_clamp = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: depth_bias_clamp = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: fill_mode_non_solid = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: depth_bounds = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: wide_lines = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: large_points = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: alpha_to_one = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: multi_view_port = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sampler_anisotropy = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: texture_compression_etc2 = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: texture_compression_astc_ldr = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: texture_compression_bc = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: occlusion_query_precise = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: pipeline_statistics_query = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: vertex_pipeline_stores_and_atomics = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: fragment_stores_and_atomics = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_tessellation_and_geometry_point_size = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_image_gather_extended = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_storage_image_extended_formats = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_storage_image_multisample = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_storage_image_read_without_format = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_storage_image_write_without_format = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_uniform_buffer_array_dynamic_indexing = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_sampled_image_array_dynamic_indexing = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_storage_buffer_array_dynamic_indexing = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_storage_image_array_dynamic_indexing = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_clip_distance = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_cull_distance = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_float64 = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_int64 = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_int16 = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_resource_residency = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: shader_resource_min_lod = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sparse_binding = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sparse_residency_buffer = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sparse_residency_image_2d = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sparse_residency_image_3d = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sparse_residency_2_samples = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sparse_residency_4_samples = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sparse_residency_8_samples = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sparse_residency_16_samples = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: sparse_residency_aliased = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: variable_multisample_rate = VK_FALSE
    ! VkBool32
    integer(c_int32_t) :: inherited_queries = VK_FALSE
  end type vk_physical_device_features


  !? VkExtent3D.
  type, bind(c) :: vk_extent_3d
    ! uint32_t
    integer(c_int32_t) :: width = 0
    ! uint32_t
    integer(c_int32_t) :: height = 0
    ! uint32_t
    integer(c_int32_t) :: depth = 0
  end type vk_extent_3d


  !? VkQueueFamilyProperties.
  type, bind(c) :: vk_queue_family_properties
    ! uint32_t [VkQueueFlags]
    integer(c_int32_t) :: queue_flags = 0
    ! uint32_t
    integer(c_int32_t) :: queue_count = 0
    ! uint32_t
    integer(c_int32_t) :: time_stamp_valid_bits = 0
    ! VkExtent3D
    type(vk_extent_3d) :: min_image_transfer_granularity
  end type vk_queue_family_properties


  !? VkDeviceQueueCreateInfo.
  type, bind(c) :: vk_device_queue_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t [VkDeviceQueueCreateFlags]
    integer(c_int32_t) :: flags = 0
    ! uint32_t
    integer(c_int32_t) :: queue_family_index = 0
    ! uint32_t
    integer(c_int32_t) :: queue_count = 0
    ! const float *
    type(c_ptr) :: p_queue_priorities = c_null_ptr
  end type vk_device_queue_create_info


  !? VkDeviceCreateInfo.
  type, bind(c) :: vk_device_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t [VkDeviceCreateFlags]
    integer(c_int32_t) :: flags = 0
    ! uint32
    integer(c_int32_t) :: queue_create_info_count = 0
    ! const VkDeviceQueueCreateInfo *
    type(c_ptr) :: p_queue_create_infos = c_null_ptr
    !! enabledLayerCount is deprecated and should not be used
    ! uint32_t
    integer(c_int32_t) :: enabled_layer_count = 0
    !! ppEnabledLayerNames is deprecated and should not be used
    ! const char* const*
    type(c_ptr) :: pp_enabled_layer_names = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: enabled_extension_count = 0
    ! const char* const*
    type(c_ptr) :: pp_enabled_extension_names = c_null_ptr
    ! const VkPhysicalDeviceFeatures*
    type(c_ptr) :: p_enabled_features = c_null_ptr
  end type vk_device_create_info


  !? VkExtent2D.
  type, bind(c) :: vk_extent_2d
    ! uint32_t
    integer(c_int32_t) :: width = 0
    ! uint32_t
    integer(c_int32_t) :: height = 0
  end type vk_extent_2d


  !? VkSurfaceCapabilitiesKHR.
  type, bind(c) :: vk_surface_capabilities_khr
    ! uint32_t
    integer(c_int32_t) :: min_image_count = 0
    ! uint32_t
    integer(c_int32_t) :: max_image_count = 0
    ! VkExtent2D
    type(vk_extent_2d) :: current_extent
    ! VkExtent2D
    type(vk_extent_2d) :: min_image_extent
    ! VkExtent2D
    type(vk_extent_2d) :: max_image_extent
    ! uint32_t
    integer(c_int32_t) :: max_image_array_layers = 0
    ! uint32_t [VkSurfaceTransformFlagsKHR]
    integer(c_int32_t) :: supported_transforms = 0
    ! uint32_t [VkSurfaceTransformFlagBitsKHR]
    integer(c_int32_t) :: current_transform = 0
    ! uint32_t [VkCompositeAlphaFlagsKHR]
    integer(c_int32_t) :: supported_composite_alpha = 0
    ! uint32_t [VkImageUsageFlags]
    integer(c_int32_t) :: supported_usage_flags = 0
  end type vk_surface_capabilities_khr


  !? VkSurfaceFormatKHR.
  type, bind(c) :: vk_surface_format_khr
    ! uint32_t [VkFormat]
    integer(c_int32_t) :: format = 0
    ! uint32_t [VkColorSpaceKHR]
    integer(c_int32_t) :: color_space = 0
  end type vk_surface_format_khr


  !? VkSwapchainCreateInfoKHR.
  type, bind(c) :: vk_swapchain_create_info_khr
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t [VkSwapchainCreateFlagsKHR]
    integer(c_int32_t) :: flags = 0
    ! VkSurfaceKHR
    integer(c_int64_t) :: surface = 0
    ! uint32_t
    integer(c_int32_t) :: min_image_count = 0
    ! uint32_t [VkFormat]
    integer(c_int32_t) :: image_format = 0
    ! uint32_t [VkColorSpaceKHR]
    integer(c_int32_t) :: image_color_space = 0
    type(vk_extent_2d) :: image_extent
    ! uint32_t
    integer(c_int32_t) :: image_array_layers = 0
    ! uint32_t [VkImageUsageFlags]
    integer(c_int32_t) :: image_usage = 0
    ! uint32_t [VkSharingMode]
    integer(c_int32_t) :: image_sharing_mode = 0
    ! uint32_t
    integer(c_int32_t) :: queue_family_index_count = 0
    ! const uint32_t*
    type(c_ptr) :: p_queue_family_indices = c_null_ptr
    ! uint32_t [VkSurfaceTransformFlagBitsKHR]
    integer(c_int32_t) :: pre_transform = 0
    ! uint32_t [VkCompositeAlphaFlagBitsKHR]
    integer(c_int32_t) :: composite_alpha = 0
    ! uint32_t [VkPresentModeKHR]
    integer(c_int32_t) :: present_mode = 0
    ! VkBool32
    integer(c_int32_t) :: clipped = 0
    ! VkSwapchainKHR
    integer(c_int64_t) :: old_swapchain = 0
  end type vk_swapchain_create_info_khr


  !? VkComponentMapping.
  type, bind(c) :: vk_component_mapping
    ! VkComponentSwizzle
    integer(c_int32_t) :: r = 0
    ! VkComponentSwizzle
    integer(c_int32_t) :: g = 0
    ! VkComponentSwizzle
    integer(c_int32_t) :: b = 0
    ! VkComponentSwizzle
    integer(c_int32_t) :: a = 0
  end type vk_component_mapping


  !? VkImageSubresourceRange.
  type, bind(c) :: vk_image_subresource_range
    ! uint32_t [VkImageAspectFlags]
    integer(c_int32_t) :: aspect_mask = 0
    ! uint32_t
    integer(c_int32_t) :: base_mip_level = 0
    ! uint32_t
    integer(c_int32_t) :: level_count = 0
    ! uint32_t
    integer(c_int32_t) :: base_array_layer = 0
    ! uint32_t
    integer(c_int32_t) :: layer_count = 0
  end type vk_image_subresource_range


  !? VkImageViewCreateInfo.
  type, bind(c) :: vk_image_view_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t [VkImageViewCreateFlags]
    integer(c_int32_t) :: flags = 0
    ! VkImage
    integer(c_int64_t) :: image = 0
    ! VkImageViewType
    integer(c_int32_t) :: view_type = 0
    ! VkFormat
    integer(c_int32_t) :: format = 0
    ! VkComponentMapping
    type(vk_component_mapping) :: components
    ! VkImageSubresourceRange
    type(vk_image_subresource_range) :: subresource_range
  end type vk_image_view_create_info


  !? VkShaderModuleCreateInfo.
  type, bind(c) :: vk_shader_module_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkFlags
    integer(c_int32_t) :: flags = 0
    ! size_t
    integer(c_size_t) :: code_size = 0
    ! const uint32_t *
    type(c_ptr) :: p_code = c_null_ptr
  end type vk_shader_module_create_info


  !? VkPipelineShaderStageCreateInfo.
  type, bind(c) :: vk_pipeline_shader_stage_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkFlags
    integer(c_int32_t) :: flags = 0
    ! VkShaderStageFlagBits
    integer(c_int32_t) :: stage = 0
    ! VkShaderModule
    integer(c_int64_t) :: module = 0
    ! const char*
    type(c_ptr) :: p_name = c_null_ptr
    ! const VkSpecializationInfo *
    type(c_ptr) :: p_specialization_info = c_null_ptr
  end type vk_pipeline_shader_stage_create_info


  !? VkPipelineDynamicStateCreateInfo.
  type, bind(c) :: vk_pipeline_dynamic_state_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineDynamicStateCreateFlags
    integer(c_int32_t) :: flags = 0
    ! uint32_t
    integer(c_int32_t) :: dynamic_state_count = 0
    ! const VkDynamicState *
    type(c_ptr) :: p_dynamic_states = c_null_ptr
  end type vk_pipeline_dynamic_state_create_info


  !? VkPipelineVertexInputStateCreateInfo.
  type, bind(c) :: vk_pipeline_vertex_input_state_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineVertexInputStateCreateFlags
    integer(c_int32_t) :: flags = 0
    ! uint32_t
    integer(c_int32_t) :: vertex_binding_description_count = 0
    ! const VkVertexInputBindingDescription *
    type(c_ptr) :: p_vertex_binding_descriptions = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: vertex_attribute_description_count = 0
    ! const VkVertexInputAttributeDescription *
    type(c_ptr) :: p_vertex_attribute_descriptions = c_null_ptr
  end type vk_pipeline_vertex_input_state_create_info


  !? VkPipelineInputAssemblyStateCreateInfo.
  type, bind(c) :: vk_pipeline_input_assembly_state_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineInputAssemblyStateCreateFlags
    integer(c_int32_t) :: flags = 0
    ! VkPrimitiveTopology
    integer(c_int32_t) :: topology = 0
    ! VkBool32
    integer(c_int32_t) :: primitive_restart_enabled = 0
  end type vk_pipeline_input_assembly_state_create_info


  !? VkViewport.
  type, bind(c) :: vk_viewport
    ! float
    real(c_float) :: x = 0.0
    ! float
    real(c_float) :: y = 0.0
    ! float
    real(c_float) :: width = 0.0
    ! float
    real(c_float) :: height = 0.0
    ! float
    real(c_float) :: min_depth = 0.0
    ! float
    real(c_float) :: max_depth = 0.0
  end type vk_viewport


  !? VkOffset2D.
  type, bind(c) :: vk_offset_2d
    ! int32_t
    integer(c_int32_t) :: x = 0
    ! int32_t
    integer(c_int32_t) :: y = 0
  end type vk_offset_2d


  !? VkRect2D.
  type, bind(c) :: vk_rect_2d
    ! VkOffset2D
    type(vk_offset_2d) :: offset
    ! VkExtent2D
    type(vk_extent_2d) :: extent
  end type vk_rect_2d


  !? VkPipelineViewportStateCreateInfo.
  type, bind(c) :: vk_pipeline_viewport_state_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineViewportStateCreateFlags
    integer(c_int32_t) :: flags = 0
    ! uint32_t
    integer(c_int32_t) :: viewport_count = 0
    ! const VkViewport *
    type(c_ptr) :: p_viewports = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: scissor_count = 0
    ! const VkRect2D*
    type(c_ptr) :: p_scissors = c_null_ptr
  end type vk_pipeline_viewport_state_create_info


  !? VkPipelineRasterizationStateCreateInfo.
  type, bind(c) :: vk_pipeline_rasterization_state_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineRasterizationStateCreateFlags
    integer(c_int32_t) :: flags = 0
    ! VkBool32
    integer(c_int32_t) :: depth_clamp_enable = 0
    ! VkBool32
    integer(c_int32_t) :: rasterizer_discard_enable = 0
    ! VkPolygonMode
    integer(c_int32_t) :: polygon_mode = 0
    ! VkCullModeFlags
    integer(c_int32_t) :: cull_mode = 0
    ! VkFrontFace
    integer(c_int32_t) :: front_face = 0
    ! VkBool32
    integer(c_int32_t) :: depth_bias_enable = 0
    ! float
    real(c_float) :: depth_bias_constant_factor = 0.0
    ! float
    real(c_float) :: depth_bias_clamp = 0.0
    ! float
    real(c_float) :: depth_bias_slope_factor = 0.0
    ! float
    real(c_float) :: line_width = 0.0
  end type vk_pipeline_rasterization_state_create_info


  !? VkPipelineColorBlendAttachmentState.
  type, bind(c) :: vk_pipeline_color_blend_attachment_state
    ! VkBool32
    integer(c_int32_t) :: blend_enable = 0
    ! VkBlendFactor
    integer(c_int32_t) :: src_color_blend_factor = 0
    ! VkBlendFactor
    integer(c_int32_t) :: dst_color_blend_factor = 0
    ! VkBlendOp
    integer(c_int32_t) :: color_blen_op = 0
    ! VkBlendFactor
    integer(c_int32_t) :: src_alpha_blend_factor = 0
    ! VkBlendFactor
    integer(c_int32_t) :: dst_alpha_blend_factor = 0
    ! VkBlendOp
    integer(c_int32_t) :: alpha_blend_op = 0
    ! VkColorComponentFlags
    integer(c_int32_t) :: color_write_mask = 0
  end type vk_pipeline_color_blend_attachment_state



  !? CUSTOM TYPES. ===============================================================


  type :: forvulkan_queue_family_indices
    ! uint32_t
    integer(c_int32_t) :: graphics_family = 0
    logical(c_bool) :: graphics_family_has_value = .false.
    ! uint32_t
    integer(c_int32_t) :: present_family = 0
    logical(c_bool) :: present_family_has_value = .false.
  end type forvulkan_queue_family_indices


  type :: forvulkan_swapchain_support_details
    type(vk_surface_capabilities_khr) :: capabilities
    ! VkSurfaceFormatKHR
    type(vec) :: formats
    ! uint32_t [VkPresentModeKHR]
    type(vec) :: present_modes
  end type forvulkan_swapchain_support_details


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


    subroutine vk_get_physical_device_properties(physical_device, p_properties) bind(c, name = "vkGetPhysicalDeviceProperties")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkPhysicalDevice
      integer(c_int64_t), intent(in), value :: physical_device
      ! VkPhysicalDeviceProperties *
      type(c_ptr), intent(in), value :: p_properties
    end subroutine vk_get_physical_device_properties


    subroutine vk_get_physical_device_features(physical_device, p_features) bind(c, name = "vkGetPhysicalDeviceFeatures")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkPhysicalDevice
      integer(c_int64_t), intent(in), value :: physical_device
      ! VkPhysicalDeviceFeatures *
      type(c_ptr), intent(in), value :: p_features
    end subroutine vk_get_physical_device_features


    subroutine vk_get_physical_device_queue_family_properties(physical_device, p_queue_family_property_count, p_queue_family_properties) bind(c, name = "vkGetPhysicalDeviceQueueFamilyProperties")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkPhysicalDevice
      integer(c_int64_t), intent(in), value :: physical_device
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_queue_family_property_count
      ! VkQueueFamilyProperties *
      type(c_ptr), intent(in), value :: p_queue_family_properties
    end subroutine vk_get_physical_device_queue_family_properties


    function vk_create_device(physical_device, p_create_info, p_allocator, p_logical_device) result(vk_result) bind(c, name = "vkCreateDevice")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkPhysicalDevice
      integer(c_int64_t), intent(in), value :: physical_device
      ! const VkDeviceCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      ! VkDevice *
      integer(c_int64_t), intent(inout) :: p_logical_device
      integer(c_int32_t) :: vk_result
    end function vk_create_device


    subroutine vk_destroy_device(logical_device, p_allocator) bind(c, name = "vkDestroyDevice")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkDevice
      integer(c_int64_t), intent(in), value :: logical_device
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_device


    subroutine vk_get_device_queue(logical_device, queue_family_index, queue_index, p_queue) bind(c, name = "vkGetDeviceQueue")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkDevice
      integer(c_int64_t), intent(in), value :: logical_device
      ! uint32_t
      integer(c_int32_t), intent(in), value :: queue_family_index
      ! uint32_t
      integer(c_int32_t), intent(in), value ::  queue_index
      ! VkQueue *
      integer(c_int64_t), intent(inout) :: p_queue
    end subroutine vk_get_device_queue


    subroutine vk_destroy_surface_khr(instance, window_surface, p_allocator) bind(c, name = "vkDestroySurfaceKHR")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkInstance
      integer(c_int64_t), intent(in), value :: instance
      ! VkSurfaceKHR
      integer(c_int64_t), intent(in), value :: window_surface
      ! const VkAllocationCallbacks *
      type(c_funptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_surface_khr


    function vk_get_physical_device_surface_support_khr(physical_device, queue_family_index, window_surface, p_supported) result(vk_result) bind(c, name = "vkGetPhysicalDeviceSurfaceSupportKHR")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkPhysicalDevice
      integer(c_int64_t), intent(in), value :: physical_device
      ! uint32_t
      integer(c_int32_t), intent(in), value :: queue_family_index
      ! VkSurfaceKHR
      integer(c_int64_t), intent(in), value :: window_surface
      ! VkBool32 *
      integer(c_int32_t), intent(inout) :: p_supported
      integer(c_int32_t) :: vk_result
    end function vk_get_physical_device_surface_support_khr


    function vk_enumerate_device_extension_properties(physical_device, p_layer_name, p_property_count, p_properties) result(vk_result) bind(c, name = "vkEnumerateDeviceExtensionProperties")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkPhysicalDevice
      integer(c_int64_t), intent(in), value :: physical_device
      ! const char *
      type(c_ptr), intent(in), value :: p_layer_name
      ! uint32 *
      integer(c_int32_t), intent(inout) :: p_property_count
      ! VkExtensionProperties *
      type(c_ptr), intent(in), value :: p_properties
      integer(c_int32_t) :: vk_result
    end function vk_enumerate_device_extension_properties


    function vk_get_physical_device_surface_capabilities_khr(physical_device, surface, p_surface_capabilities) result(vk_result) bind(c, name = "vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkPhysicalDevice
      integer(c_int64_t), intent(in), value :: physical_device
      ! VkSurfaceKHR
      integer(c_int64_t), intent(in), value :: surface
      ! VkSurfaceCapabilitiesKHR *
      type(c_ptr), intent(in), value :: p_surface_capabilities
      integer(c_int32_t) :: vk_result
    end function vk_get_physical_device_surface_capabilities_khr


    function vk_get_physical_device_surface_formats_khr(physical_device, surface, p_surface_format_count, p_surface_formats) result(vk_result) bind(c, name = "vkGetPhysicalDeviceSurfaceFormatsKHR")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkPhysicalDevice
      integer(c_int64_t), intent(in), value :: physical_device
      ! VkSurfaceKHR
      integer(c_int64_t), intent(in), value :: surface
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_surface_format_count
      ! VkSurfaceFormatKHR *
      type(c_ptr), intent(in), value :: p_surface_formats
      integer(c_int32_t) :: vk_result
    end function vk_get_physical_device_surface_formats_khr


    function vk_get_physical_device_surface_present_modes_khr(physical_device, surface, p_present_mode_count, p_present_modes) result(vk_result) bind(c, name = "vkGetPhysicalDeviceSurfacePresentModesKHR")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkPhysicalDevice
      integer(c_int64_t), intent(in), value :: physical_device
      ! VkSurfaceKHR
      integer(c_int64_t), intent(in), value :: surface
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_present_mode_count
      ! VkPresentModeKHR *
      type(c_ptr), intent(in), value :: p_present_modes
      integer(c_int32_t) :: vk_result
    end function vk_get_physical_device_surface_present_modes_khr


    function vk_create_swapchain_khr(logical_device, p_create_info, p_allocator, p_swapchain) result(vk_result) bind(c, name = "vkCreateSwapchainKHR")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkDevice
      integer(c_int64_t), intent(in), value :: logical_device
      ! const VkSwapchainCreateInfoKHR *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      ! VkSwapchainKHR *
      integer(c_int64_t), intent(inout) :: p_swapchain
      integer(c_int32_t) :: vk_result
    end function vk_create_swapchain_khr


    subroutine vk_destroy_swapchain_khr(logical_device, swapchain, p_allocator) bind(c, name = "vkDestroySwapchainKHR")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkDevice
      integer(c_int64_t), intent(in), value :: logical_device
      ! VkSwapchainKHR
      integer(c_int64_t), intent(in), value :: swapchain
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_swapchain_khr


    function vk_get_swapchain_images_khr(logical_device, swapchain, p_swapchain_image_count, p_swapchain_images) result(vk_result) bind(c, name = "vkGetSwapchainImagesKHR")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkDevice
      integer(c_int64_t), intent(in), value :: logical_device
      ! VkSwapchainKHR
      integer(c_int64_t), intent(in), value :: swapchain
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_swapchain_image_count
      ! VkImage *
      type(c_ptr), intent(in), value :: p_swapchain_images
      integer(c_int32_t) :: vk_result
    end function vk_get_swapchain_images_khr


    function vk_create_image_view(logical_device, p_create_info, p_allocator, p_view) result(vk_result) bind(c, name = "vkCreateImageView")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkDevice
      integer(c_int64_t), intent(in), value :: logical_device
      ! const VkImageViewCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      ! VkImageView *
      type(c_ptr), intent(in), value :: p_view
      integer(c_int32_t) :: vk_result
    end function vk_create_image_view


    subroutine vk_destroy_image_view(logical_device, image_view, p_allocator) bind(c, name = "vkDestroyImageView")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkDevice
      integer(c_int64_t), intent(in), value :: logical_device
      ! VkImageView
      integer(c_int64_t), intent(in), value :: image_view
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_image_view


    function vk_create_shader_module(logical_device, p_create_info, p_allocator, p_shader_module) result(vk_result) bind(c, name = "vkCreateShaderModule")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkDevice
      integer(c_int64_t), intent(in), value :: logical_device
      ! const VkShaderModuleCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      ! VkShaderModule *
      integer(c_int64_t), intent(inout) :: p_shader_module
      integer(c_int32_t) :: vk_result
    end function vk_create_shader_module


    subroutine vk_destroy_shader_module(logical_device, shader_module, p_allocator) bind(c, name = "vkDestroyShaderModule")
      use, intrinsic :: iso_c_binding
      implicit none

      ! VkDevice
      integer(c_int64_t), intent(in), value :: logical_device
      ! VkShaderModule
      integer(c_int64_t), intent(in), value :: shader_module
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_shader_module


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


end module forvulkan
