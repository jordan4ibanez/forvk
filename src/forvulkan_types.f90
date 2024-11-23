module forvulkan_types
  use, intrinsic :: iso_c_binding
  use :: forvulkan_parameters
  use :: vector
  implicit none

!? FORTRANIFIED OPAQUE TYPES. ===============================================================


  ! These types allow less confusion and static typing when you're using Forvulkan.
  ! The naming inside does not matter, you're never supposed to touch it. It's an opaque data shell.


  !? VkInstance.
  type, bind(c) :: vk_instance
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_instance


  !? VkDebugUtilsMessengerEXT.
  type, bind(c) :: vk_debug_utils_messenger_ext
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_debug_utils_messenger_ext


  !? VkSurfaceKHR.
  type, bind(c) :: vk_surface_khr
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_surface_khr


  !? VkPhysicalDevice.
  type, bind(c) :: vk_physical_device
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_physical_device


  !? VkDevice.
  type, bind(c) :: vk_device
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_device


  !? VkQueue.
  type, bind(c) :: vk_queue
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_queue


  !? VkSwapchainKHR.
  type, bind(c) :: vk_swapchain_khr
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_swapchain_khr


  !? VkShaderModule.
  type, bind(c) :: vk_shader_module
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_shader_module


  !? VkImage.
  type, bind(c) :: vk_image
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_image


  !? VkImageView.
  type, bind(c) :: vk_image_view
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_image_view


  !? VkPipelineLayout.
  type, bind(c) :: vk_pipeline_layout
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_pipeline_layout


  !? VkRenderPass.
  type, bind(c) :: vk_render_pass
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_render_pass


  !? VkPipeline.
  type, bind(c) :: vk_pipeline
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_pipeline


  !? VkFramebuffer.
  type, bind(c) :: vk_framebuffer
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_framebuffer


  !? VkCommandPool.
  type, bind(c) :: vk_command_pool
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_command_pool


  !? VkCommandBuffer.
  type, bind(c) :: vk_command_buffer
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_command_buffer


  !? VkSemaphore.
  type, bind(c) :: vk_semaphore
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_semaphore


  !? VkFence.
  type, bind(c) :: vk_fence
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_fence


  !? VkBuffer.
  type, bind(c) :: vk_buffer
    integer(c_int64_t) :: data = VK_NULL_HANDLE
  end type vk_buffer


!? FORTRANIFIED DATA TYPES. ===============================================================


  ! Data types are like opaque types, but it's okay to modify the internals.


  !? VkFormat.
  type, bind(c) :: vk_format
    integer(c_int32_t) :: data = 0
  end type vk_format


!? REGULAR TYPES. ===============================================================


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
    type(vk_extent_2d) :: current_extent
    type(vk_extent_2d) :: min_image_extent
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
    type(vk_surface_khr) :: surface
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
    type(vk_swapchain_khr) :: old_swapchain
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
    type(vk_image) :: image
    ! Vk ImageViewType
    integer(c_int32_t) :: view_type = 0
    type(vk_format) :: format
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
    type(vk_shader_module) :: module
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


  !? VkVertexInputBindingDescription.
  type, bind(c) :: vk_vertex_input_binding_description
    ! uint32_t
    integer(c_int32_t) :: binding = 0
    ! uint32_t
    integer(c_int32_t) :: stride = 0
    ! VkVertexInputRate
    integer(c_int32_t) :: input_rate = 0
  end type vk_vertex_input_binding_description


  !? VkVertexInputAttributeDescription.
  type, bind(c) :: vk_vertex_input_attribute_description
    ! uint32_t
    integer(c_int32_t) :: location = 0
    ! uint32_t
    integer(c_int32_t) :: binding = 0
    type(vk_format) :: format
    ! uint32_t
    integer(c_int32_t) :: offset = 0
  end type vk_vertex_input_attribute_description


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
    integer(c_int32_t) :: color_blend_op = 0
    ! VkBlendFactor
    integer(c_int32_t) :: src_alpha_blend_factor = 0
    ! VkBlendFactor
    integer(c_int32_t) :: dst_alpha_blend_factor = 0
    ! VkBlendOp
    integer(c_int32_t) :: alpha_blend_op = 0
    ! VkColorComponentFlags
    integer(c_int32_t) :: color_write_mask = 0
  end type vk_pipeline_color_blend_attachment_state


  !? VkPipelineLayoutCreateInfo.
  type, bind(c) :: vk_pipeline_layout_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineLayoutCreateFlags
    integer(c_int32_t) :: flags = 0
    ! uint32_t
    integer(c_int32_t) :: set_layout_count = 0
    ! const VkDescriptorSetLayout *
    type(c_ptr) :: p_set_layouts = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: push_constant_range_count = 0
    ! const VkPushConstantRange *
    type(c_ptr) :: p_push_constant_ranges = c_null_ptr
  end type vk_pipeline_layout_create_info


  !? VkAttachmentDescription.
  type, bind(c) :: vk_attachment_description
    ! VkAttachmentDescriptionFlags
    integer(c_int32_t) :: flags = 0
    type(vk_format) :: format
    ! VkSampleCountFlagBits
    integer(c_int32_t) :: samples = 0
    ! VkAttachmentLoadOp
    integer(c_int32_t) :: load_op = 0
    ! VkAttachmentStoreOp
    integer(c_int32_t) :: store_op = 0
    ! VkAttachmentLoadOp
    integer(c_int32_t) :: stencil_load_op = 0
    ! VkAttachmentStoreOp
    integer(c_int32_t) :: stencil_store_op = 0
    ! VkImageLayout
    integer(c_int32_t) :: initial_layout = 0
    ! VkImageLayout
    integer(c_int32_t) :: final_layout = 0
  end type vk_attachment_description


  !? VkAttachmentReference.
  type, bind(c) :: vk_attachment_reference
    ! uint32_t
    integer(c_int32_t) :: attachment = 0
    ! VkImageLayout
    integer(c_int32_t) :: layout = 0
  end type vk_attachment_reference


  !? VkSubpassDescription.
  !* I had to slap a [_t] on there because I had to modify the way the parameter for this runs.
  !* The names conflicted.
  type, bind(c) :: vk_subpass_description_t
    ! VkSubpassDescriptionFlags
    integer(c_int32_t) :: flags = 0
    ! VkPipelineBindPoint
    integer(c_int32_t) :: pipeline_bind_point = 0
    ! uint32_t
    integer(c_int32_t) :: input_attachment_count = 0
    ! const VkAttachmentReference *
    type(c_ptr) :: p_input_attachments = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: color_attachment_count = 0
    ! const VkAttachmentReference *
    type(c_ptr) :: p_color_attachments = c_null_ptr
    ! const VkAttachmentReference *
    type(c_ptr) :: p_resolve_attachments = c_null_ptr
    ! const VkAttachmentReference *
    type(c_ptr) :: p_depth_stencil_attachment = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: preserve_attachment_count = 0
    ! const uint32_t *
    type(c_ptr) :: p_preserve_attachments = c_null_ptr
  end type vk_subpass_description_t


  !? VkSubpassDependency.
  type, bind(c) :: vk_subpass_dependency
    ! uint32_t
    integer(c_int32_t) :: src_subpass = 0
    ! uint32_t
    integer(c_int32_t) :: dst_subpass = 0
    ! VkPipelineStageFlags
    integer(c_int32_t) :: src_stage_mask = 0
    ! VkPipelineStageFlags
    integer(c_int32_t) :: dst_stage_mask = 0
    ! VkAccessFlags
    integer(c_int32_t) :: src_access_mask = 0
    ! VkAccessFlags
    integer(c_int32_t) :: dst_access_mask = 0
    ! VkDependencyFlags
    integer(c_int32_t) :: dependency_flags = 0
  end type vk_subpass_dependency


  !? VkRenderPassCreateInfo.
  type, bind(c) :: vk_render_pass_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkRenderPassCreateFlags
    integer(c_int32_t) :: flags = 0
    ! uint32_t
    integer(c_int32_t) :: attachment_count = 0
    ! const VkAttachmentDescription *
    type(c_ptr) :: p_attachments = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: subpass_count = 0
    ! const VkSubpassDescription *
    type(c_ptr) :: p_subpasses = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: dependency_count = 0
    ! const VkSubpassDependency *
    type(c_ptr) :: p_dependencies = c_null_ptr
  end type vk_render_pass_create_info


  !? VkPipelineTessellationStateCreateInfo.
  type, bind(c) :: vk_pipeline_tesselation_state_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineTessellationStateCreateFlags
    integer(c_int32_t) :: flags = 0
    ! uint32_t
    integer(c_int32_t) :: patch_control_points = 0
  end type vk_pipeline_tesselation_state_create_info


  !? VkPipelineMultisampleStateCreateInfo.
  type, bind(c) :: vk_pipeline_multisample_state_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineMultisampleStateCreateFlags
    integer(c_int32_t) :: flags = 0
    ! VkSampleCountFlagBits
    integer(c_int32_t) :: rasterization_samples = 0
    ! VkBool32
    integer(c_int32_t) :: sample_shading_enable = 0
    ! float
    real(c_float) :: min_sample_shading = 0.0
    ! const VkSampleMask*
    type(c_ptr) :: p_sample_mask = c_null_ptr
    ! VkBool32
    integer(c_int32_t) :: alpha_to_coverage_enable = 0
    ! VkBool32
    integer(c_int32_t) :: alpha_to_one_enable = 0
  end type vk_pipeline_multisample_state_create_info


  !? VkStencilOpState.
  type, bind(c) :: vk_stencil_op_state
    ! VkStencilOp
    integer(c_int32_t) :: fail_op = 0
    ! VkStencilOp
    integer(c_int32_t) :: pass_op = 0
    ! VkStencilOp
    integer(c_int32_t) :: depth_fail_op = 0
    ! VkCompareOp
    integer(c_int32_t) :: compare_op = 0
    ! uint32_t
    integer(c_int32_t) :: compare_mask = 0
    ! uint32_t
    integer(c_int32_t) :: write_mask = 0
    ! uint32_t
    integer(c_int32_t) :: reference = 0
  end type vk_stencil_op_state


  !? VkPipelineDepthStencilStateCreateInfo.
  type, bind(c) :: vk_pipeline_depth_stencil_state_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineDepthStencilStateCreateFlags
    integer(c_int32_t) :: flags = 0
    ! VkBool32
    integer(c_int32_t) :: depth_test_enable = 0
    ! VkBool32
    integer(c_int32_t) :: depth_write_enable = 0
    ! VkCompareOp
    integer(c_int32_t) :: depth_compare_op = 0
    ! VkBool32
    integer(c_int32_t) :: depth_bounds_test_enable = 0
    ! VkBool32
    integer(c_int32_t) :: stencil_test_enable = 0
    ! VkStencilOpState
    type(vk_stencil_op_state) :: front
    ! VkStencilOpState
    type(vk_stencil_op_state) :: back
    ! float
    real(c_float) :: min_depth_bounds = 0.0
    ! float
    real(c_float) :: max_depth_bounds = 0.0
  end type vk_pipeline_depth_stencil_state_create_info


  !? VkPipelineColorBlendStateCreateInfo.
  type, bind(c) :: vk_pipeline_color_blend_state_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineColorBlendStateCreateFlags
    integer(c_int32_t) :: flags = 0
    ! VkBool32
    integer(c_int32_t) :: logical_op_enable = 0
    ! VkLogicOp
    integer(c_int32_t) :: logic_op = 0
    ! uint32_t
    integer(c_int32_t) :: attachment_count = 0
    ! const VkPipelineColorBlendAttachmentState *
    type(c_ptr) :: p_attachments = c_null_ptr
    ! float[4]
    real(c_float), dimension(4) :: blend_constants = [0.0, 0.0, 0.0, 0.0]
  end type vk_pipeline_color_blend_state_create_info


  !? VkGraphicsPipelineCreateInfo.
  type, bind(c) :: vk_graphics_pipeline_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkPipelineCreateFlags
    integer(c_int32_t) :: flags = 0
    ! uint32_t
    integer(c_int32_t) :: stage_count = 0
    ! const VkPipelineShaderStageCreateInfo *
    type(c_ptr) :: p_stages = c_null_ptr
    ! const VkPipelineVertexInputStateCreateInfo *
    type(c_ptr) :: p_vertex_input_state = c_null_ptr
    ! const VkPipelineInputAssemblyStateCreateInfo *
    type(c_ptr) :: p_input_assembly_state = c_null_ptr
    ! const VkPipelineTessellationStateCreateInfo *
    type(c_ptr) :: p_tessellation_state = c_null_ptr
    ! const VkPipelineViewportStateCreateInfo *
    type(c_ptr) :: p_viewport_state = c_null_ptr
    ! const VkPipelineRasterizationStateCreateInfo *
    type(c_ptr) :: p_rasterization_state = c_null_ptr
    ! const VkPipelineMultisampleStateCreateInfo *
    type(c_ptr) :: p_multisample_state = c_null_ptr
    ! const VkPipelineDepthStencilStateCreateInfo *
    type(c_ptr) :: p_depth_stencil_state = c_null_ptr
    ! const VkPipelineColorBlendStateCreateInfo *
    type(c_ptr) :: p_color_blend_state = c_null_ptr
    ! const VkPipelineDynamicStateCreateInfo*
    type(c_ptr) :: p_dynamic_state = c_null_ptr
    type(vk_pipeline_layout) :: layout
    type(vk_render_pass) :: render_pass
    ! uint32_t
    integer(c_int32_t) :: subpass = 0
    type(vk_pipeline) :: base_pipeline_handle
    ! int32_t
    integer(c_int32_t) :: base_pipeline_index = 0
  end type vk_graphics_pipeline_create_info


  !? VkFramebufferCreateInfo.
  type, bind(c) :: vk_framebuffer_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkFramebufferCreateFlags
    integer(c_int32_t) :: flags = 0
    type(vk_render_pass) :: render_pass
    ! uint32_t
    integer(c_int32_t) :: attachment_count = 0
    ! const VkImageView *
    type(c_ptr) :: p_attachments = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: width = 0
    ! uint32_t
    integer(c_int32_t) :: height = 0
    ! uint32_t
    integer(c_int32_t) :: layers = 0
  end type vk_framebuffer_create_info


  !? VkCommandPoolCreateInfo.
  type, bind(c) :: vk_command_pool_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkCommandPoolCreateFlags
    integer(c_int32_t) :: flags = 0
    ! uint32_t
    integer(c_int32_t) :: queue_family_index = 0
  end type vk_command_pool_create_info


  !? VkCommandBufferAllocateInfo.
  type, bind(c) :: vk_command_buffer_allocate_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    type(vk_command_pool) :: command_pool
    ! VkCommandBufferLevel
    integer(c_int32_t) :: level = 0
    ! uint32_t
    integer(c_int32_t) :: command_buffer_count = 0
  end type vk_command_buffer_allocate_info


  !? VkCommandBufferInheritanceInfo.
  type, bind(c) :: vk_command_buffer_inheritence_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    type(vk_render_pass) :: render_pass
    ! uint32_t
    integer(c_int32_t) :: subpass = 0
    type(vk_framebuffer) :: framebuffer
    ! VkBool32
    integer(c_int32_t) :: occlusion_query_enable = 0
    ! VkQueryControlFlags
    integer(c_int32_t) :: query_flags = 0
    ! VkQueryPipelineStatisticFlags
    integer(c_int32_t) :: pipeline_statistics = 0
  end type vk_command_buffer_inheritence_info


  !? VkCommandBufferBeginInfo.
  type, bind(c) :: vk_command_buffer_begin_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkCommandBufferUsageFlags
    integer(c_int32_t) :: flags = 0
    ! const VkCommandBufferInheritanceInfo *
    type(c_ptr) :: p_inheritence_info = c_null_ptr
  end type vk_command_buffer_begin_info


  !! START HACKJOB.

  ! I have bunched these together so you can read with more of a context.

  !? VkClearValue.
  !* IMPLEMENTATION NOTE: vk_clear_* is a C union. You have to pick one of these (3): [VkClearValue]

  !? VkClearColorValue.
  !* IMPLEMENTATION NOTE: vk_clear_color_* is a C union. You will have to pick one of these (2): [VkClearColorValue]
  type, bind(c) :: vk_clear_color_value_f32
    real(c_float), dimension(4) :: data = [0.0, 0.0, 0.0, 1.0]
  end type
  type, bind(c) :: vk_clear_color_value_i32
    integer(c_int32_t), dimension(4) :: data = [0, 0, 0, 0]
  end type
  !* END NOTE ON: vk_clear_color* [VkClearColorValue]

  !? VkClearDepthStencilValue
  type, bind(c) :: vk_clear_depth_stencil_value
    ! float
    real(c_float) :: depth = 0.0
    ! uint32_t
    integer(c_int32_t) :: stencil = 0
  end type vk_clear_depth_stencil_value

  !* END NOTE ON: vk_clear_* [VkClearValue]

  !! END HACKJOB


  !? VkRenderPassBeginInfo.
  type, bind(c) :: vk_render_pass_begin_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    type(vk_render_pass) :: render_pass
    type(vk_framebuffer) :: framebuffer
    ! VkRect2D
    type(vk_rect_2d) :: render_area
    ! uint32_t
    integer(c_int32_t) :: clear_value_count = 0
    ! const VkClearValue * !* Please read the note at: [VkClearValue]
    type(c_ptr) :: p_clear_values = c_null_ptr
  end type vk_render_pass_begin_info


  !? VkSemaphoreCreateInfo.
  type, bind(c) :: vk_semaphore_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkSemaphoreCreateFlags
    integer(c_int32_t) :: flags = 0
  end type vk_semaphore_create_info


  !? VkFenceCreateInfo.
  type, bind(c) :: vk_fence_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkFenceCreateFlags
    integer(c_int32_t) :: flags = 0
  end type vk_fence_create_info


  !? VkSubmitInfo.
  type, bind(c) :: vk_submit_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: wait_semaphore_count = 0
    ! const VkSemaphore *
    type(c_ptr) :: p_wait_semaphores = c_null_ptr
    ! const VkPipelineStageFlags *
    type(c_ptr) :: p_wait_dst_stage_mask = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: command_buffer_count = 0
    ! const VkCommandBuffer *
    type(c_ptr) :: p_command_buffers = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: signal_semaphore_count = 0
    ! const VkSemaphore *
    type(c_ptr) :: p_signal_semaphores = c_null_ptr
  end type vk_submit_info


  !? VkPresentInfoKHR.
  type, bind(c) :: vk_present_info_khr
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: wait_semaphore_count = 0
    ! const VkSemaphore *
    type(c_ptr) :: p_wait_semaphores = c_null_ptr
    ! uint32_t
    integer(c_int32_t) :: swapchain_count = 0
    ! const VkSwapchainKHR *
    type(c_ptr) :: p_swapchains = c_null_ptr
    ! const uint32_t *
    type(c_ptr) :: p_image_indices = c_null_ptr
    ! VkResult *
    type(c_ptr) :: p_results = c_null_ptr
  end type vk_present_info_khr


  !? VkBufferCreateInfo.
  type, bind(c) :: vk_buffer_create_info
    ! uint32_t [VkStructureType]
    integer(c_int32_t) :: s_type = 0
    ! const void *
    type(c_ptr) :: p_next = c_null_ptr
    ! VkBufferCreateFlags
    integer(c_int32_t) :: flags = 0
    ! VkDeviceSize
    integer(c_int64_t) :: size = 0
    ! VkBufferUsageFlags
    integer(c_int32_t) :: usage = 0
    ! VkSharingMode
    integer(c_int32_t) :: sharing_mode = 0
    ! uint32_t
    integer(c_int32_t) :: queue_family_index_count = 0
    ! const uint32_t*
    type(c_ptr) :: p_queue_family_indices = c_null_ptr
  end type vk_buffer_create_info


  !? VkMemoryRequirements.
  type, bind(c) :: vk_memory_requirements
    ! VkDeviceSize
    integer(c_int64_t) :: size = 0
    ! VkDeviceSize
    integer(c_int64_t) :: alignment = 0
    ! uint32_t
    integer(c_int32_t) :: memory_type_bits = 0
  end type vk_memory_requirements


  !? VkMemoryType.
  type, bind(c) :: vk_memory_type
    ! VkMemoryPropertyFlags
    integer(c_int32_t) :: property_flags = 0
    ! uint32_t
    integer(c_int32_t) :: heap_index = 0
  end type vk_memory_type
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


end module forvulkan_types
