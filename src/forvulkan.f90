module forvulkan
  use, intrinsic :: iso_c_binding
  use :: forvulkan_parameters
  use :: forvulkan_types
  use :: vector
  implicit none


  ! https://github.com/KhronosGroup/Vulkan-Headers/blob/main/include/vulkan/vulkan_core.h
  ! Forvulkan is hand translated with love to ensure correctness. :D


!* TYPES. ============================c===================================

  !! NOTE: !!
  !! typedef uint32_t VkFlags !!
  !! vk_flags VkFlags is of type integer(c_int32_t) !!


!* C FUNCTION INTERFACES. ===============================================================


  interface


    function vk_create_instance(p_create_info, p_allocator, p_instance) result(res) bind(c, name = "vkCreateInstance")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      ! const VkInstanceCreateInfo *, const VkAllocationCallbacks *, VkInstance *
      type(c_ptr), intent(in), value :: p_create_info, p_allocator
      type(vk_instance), intent(inout) :: p_instance
      integer(c_int32_t) :: res
    end function vk_create_instance


    subroutine vk_destroy_instance(instance, p_allocator) bind(c, name = "vkDestroyInstance")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_instance), intent(in), value :: instance
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_instance


    function vk_enumerate_instance_extension_properties(p_layer_name, p_property_count, p_properties) result(vk_result) bind(c, name = "vkEnumerateInstanceExtensionProperties")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      ! char*, uint32_t*, VkExtensionProperties*
      type(c_ptr), intent(in), value :: p_layer_name, p_properties
      integer(c_int32_t), intent(inout) :: p_property_count
      ! VkResult.
      integer(c_int32_t) :: vk_result
    end function vk_enumerate_instance_extension_properties


    function vk_enumerate_instance_layer_properties(p_property_count, p_properties) result (vk_result) bind(c, name = "vkEnumerateInstanceLayerProperties")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
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
      use :: forvulkan_types
      implicit none

      type(vk_instance), intent(in), value :: instance
      ! const char *
      type(c_ptr), intent(in), value :: p_name
      type(c_funptr) :: pfn_vk_void_function
    end function vk_get_instance_proc_addr


    function vk_enumerate_physical_devices(instance, p_physical_device_count, p_physical_devices) result(vk_result) bind(c, name = "vkEnumeratePhysicalDevices")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_instance), intent(in), value :: instance
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_physical_device_count
      ! VkPhysicalDevice *
      type(c_ptr), intent(in), value :: p_physical_devices
      integer(c_int32_t) :: vk_result
    end function vk_enumerate_physical_devices


    subroutine vk_get_physical_device_properties(physical_device, p_properties) bind(c, name = "vkGetPhysicalDeviceProperties")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_physical_device), intent(in), value :: physical_device
      ! VkPhysicalDeviceProperties *
      type(c_ptr), intent(in), value :: p_properties
    end subroutine vk_get_physical_device_properties


    subroutine vk_get_physical_device_features(physical_device, p_features) bind(c, name = "vkGetPhysicalDeviceFeatures")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_physical_device), intent(in), value :: physical_device
      ! VkPhysicalDeviceFeatures *
      type(c_ptr), intent(in), value :: p_features
    end subroutine vk_get_physical_device_features


    subroutine vk_get_physical_device_queue_family_properties(physical_device, p_queue_family_property_count, p_queue_family_properties) bind(c, name = "vkGetPhysicalDeviceQueueFamilyProperties")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_physical_device), intent(in), value :: physical_device
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_queue_family_property_count
      ! VkQueueFamilyProperties *
      type(c_ptr), intent(in), value :: p_queue_family_properties
    end subroutine vk_get_physical_device_queue_family_properties


    function vk_create_device(physical_device, p_create_info, p_allocator, p_logical_device) result(vk_result) bind(c, name = "vkCreateDevice")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_physical_device), intent(in), value :: physical_device
      ! const VkDeviceCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_device), intent(inout) :: p_logical_device
      integer(c_int32_t) :: vk_result
    end function vk_create_device


    subroutine vk_destroy_device(logical_device, p_allocator) bind(c, name = "vkDestroyDevice")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_device


    subroutine vk_get_device_queue(logical_device, queue_family_index, queue_index, p_queue) bind(c, name = "vkGetDeviceQueue")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! uint32_t
      integer(c_int32_t), intent(in), value :: queue_family_index
      ! uint32_t
      integer(c_int32_t), intent(in), value ::  queue_index
      type(vk_queue), intent(inout) :: p_queue
    end subroutine vk_get_device_queue


    subroutine vk_destroy_surface_khr(instance, window_surface, p_allocator) bind(c, name = "vkDestroySurfaceKHR")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_instance), intent(in), value :: instance
      type(vk_surface_khr), intent(in), value :: window_surface
      ! const VkAllocationCallbacks *
      type(c_funptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_surface_khr


    function vk_get_physical_device_surface_support_khr(physical_device, queue_family_index, window_surface, p_supported) result(vk_result) bind(c, name = "vkGetPhysicalDeviceSurfaceSupportKHR")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_physical_device), intent(in), value :: physical_device
      ! uint32_t
      integer(c_int32_t), intent(in), value :: queue_family_index
      type(vk_surface_khr), intent(in), value :: window_surface
      ! VkBool32 *
      integer(c_int32_t), intent(inout) :: p_supported
      integer(c_int32_t) :: vk_result
    end function vk_get_physical_device_surface_support_khr


    function vk_enumerate_device_extension_properties(physical_device, p_layer_name, p_property_count, p_properties) result(vk_result) bind(c, name = "vkEnumerateDeviceExtensionProperties")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_physical_device), intent(in), value :: physical_device
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
      use :: forvulkan_types
      implicit none

      type(vk_physical_device), intent(in), value :: physical_device
      type(vk_surface_khr), intent(in), value :: surface
      ! VkSurfaceCapabilitiesKHR *
      type(c_ptr), intent(in), value :: p_surface_capabilities
      integer(c_int32_t) :: vk_result
    end function vk_get_physical_device_surface_capabilities_khr


    function vk_get_physical_device_surface_formats_khr(physical_device, surface, p_surface_format_count, p_surface_formats) result(vk_result) bind(c, name = "vkGetPhysicalDeviceSurfaceFormatsKHR")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_physical_device), intent(in), value :: physical_device
      type(vk_surface_khr), intent(in), value :: surface
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_surface_format_count
      ! VkSurfaceFormatKHR *
      type(c_ptr), intent(in), value :: p_surface_formats
      integer(c_int32_t) :: vk_result
    end function vk_get_physical_device_surface_formats_khr


    function vk_get_physical_device_surface_present_modes_khr(physical_device, surface, p_present_mode_count, p_present_modes) result(vk_result) bind(c, name = "vkGetPhysicalDeviceSurfacePresentModesKHR")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_physical_device), intent(in), value :: physical_device
      type(vk_surface_khr), intent(in), value :: surface
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_present_mode_count
      ! VkPresentModeKHR *
      type(c_ptr), intent(in), value :: p_present_modes
      integer(c_int32_t) :: vk_result
    end function vk_get_physical_device_surface_present_modes_khr


    function vk_create_swapchain_khr(logical_device, p_create_info, p_allocator, p_swapchain) result(vk_result) bind(c, name = "vkCreateSwapchainKHR")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkSwapchainCreateInfoKHR *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_swapchain_khr), intent(inout) :: p_swapchain
      integer(c_int32_t) :: vk_result
    end function vk_create_swapchain_khr


    subroutine vk_destroy_swapchain_khr(logical_device, swapchain, p_allocator) bind(c, name = "vkDestroySwapchainKHR")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_swapchain_khr), intent(in), value :: swapchain
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_swapchain_khr


    function vk_get_swapchain_images_khr(logical_device, swapchain, p_swapchain_image_count, p_swapchain_images) result(vk_result) bind(c, name = "vkGetSwapchainImagesKHR")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_swapchain_khr), intent(in), value :: swapchain
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_swapchain_image_count
      ! Vk Image * (this is an array.)
      type(c_ptr), intent(in), value :: p_swapchain_images
      integer(c_int32_t) :: vk_result
    end function vk_get_swapchain_images_khr


    function vk_create_image_view(logical_device, p_create_info, p_allocator, p_view) result(vk_result) bind(c, name = "vkCreateImageView")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkImageViewCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_image_view), intent(inout) :: p_view
      integer(c_int32_t) :: vk_result
    end function vk_create_image_view


    subroutine vk_destroy_image_view(logical_device, image_view, p_allocator) bind(c, name = "vkDestroyImageView")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_image_view), intent(in), value :: image_view
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_image_view


    function vk_create_shader_module(logical_device, p_create_info, p_allocator, p_shader_module) result(vk_result) bind(c, name = "vkCreateShaderModule")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkShaderModuleCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_shader_module), intent(inout) :: p_shader_module
      integer(c_int32_t) :: vk_result
    end function vk_create_shader_module


    subroutine vk_destroy_shader_module(logical_device, shader_module, p_allocator) bind(c, name = "vkDestroyShaderModule")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_shader_module), intent(in), value :: shader_module
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_shader_module


    function vk_create_pipeline_layout(logical_device, p_create_info, p_allocator, p_pipeline_layout) result(vk_result) bind(c, name = "vkCreatePipelineLayout")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkPipelineLayoutCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_pipeline_layout), intent(inout) :: p_pipeline_layout
      integer(c_int32_t) :: vk_result
    end function vk_create_pipeline_layout


    subroutine vk_destroy_pipeline_layout(logical_device, pipeline_layout, p_allocator) bind(c, name = "vkDestroyPipelineLayout")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_pipeline_layout), intent(in), value :: pipeline_layout
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_pipeline_layout


    function vk_create_render_pass(logical_device, p_create_info, p_allocator, p_render_pass) result(vk_result) bind(c, name = "vkCreateRenderPass")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkRenderPassCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_render_pass), intent(inout) :: p_render_pass
      integer(c_int32_t) :: vk_result
    end function vk_create_render_pass


    subroutine vk_destroy_render_pass(logical_device, render_pass, p_allocator) bind(c, name = "vkDestroyRenderPass")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_render_pass), intent(in), value :: render_pass
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_render_pass


    function vk_create_graphics_pipelines(logical_device, pipeline_cache, create_info_count, p_create_infos, p_allocator, p_pipelines) result(vk_result) bind(c, name = "vkCreateGraphicsPipelines")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! VkPipelineCache
      integer(c_int64_t), intent(in), value :: pipeline_cache
      ! uint32_t
      integer(c_int32_t), intent(in), value :: create_info_count
      ! const VkGraphicsPipelineCreateInfo *
      type(c_ptr), intent(in), value :: p_create_infos
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      !? Implementation note: I only use one graphics pipeline at the moment.
      !? This can be modified to accept a more generic if needed c_ptr.
      type(vk_pipeline), intent(inout) :: p_pipelines
      integer(c_int32_t) :: vk_result
    end function vk_create_graphics_pipelines


    subroutine vk_destroy_pipeline(logical_device, pipeline, p_allocator) bind(c, name = "vkDestroyPipeline")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_pipeline), intent(in), value :: pipeline
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_pipeline


    function vk_create_framebuffer(logical_device, p_create_info, p_allocator, p_framebuffer) result(vk_result) bind(c, name = "vkCreateFramebuffer")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkFramebufferCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_framebuffer), intent(inout) :: p_framebuffer
      integer(c_int32_t) :: vk_result
    end function vk_create_framebuffer


    subroutine vk_destroy_framebuffer(logical_device, framebuffer, p_allocator) bind(c, name = "vkDestroyFramebuffer")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_framebuffer), intent(in), value :: framebuffer
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_framebuffer


    function vk_create_command_pool(logical_device, p_create_info, p_allocator, p_command_pool) result(vk_result) bind(c, name = "vkCreateCommandPool")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkCommandPoolCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_command_pool), intent(inout) :: p_command_pool
      integer(c_int32_t) :: vk_result
    end function vk_create_command_pool


    subroutine vk_destroy_command_pool(logical_device, command_pool, p_allocator) bind(c, name = "vkDestroyCommandPool")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_command_pool), intent(in), value :: command_pool
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_command_pool


    function vk_allocate_command_buffers(logical_device, p_allocate_info, p_command_buffers) result(vk_result) bind(c, name = "vkAllocateCommandBuffers")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkCommandBufferAllocateInfo *
      type(c_ptr), intent(in), value :: p_allocate_info
      ! Vk CommandBuffer * (Array of command buffers.)
      type(c_ptr), intent(in), value :: p_command_buffers
      integer(c_int32_t) :: vk_result
    end function vk_allocate_command_buffers


    function vk_begin_command_buffer(command_buffer, p_begin_info) result(vk_result) bind(c, name = "vkBeginCommandBuffer")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_command_buffer), intent(in), value :: command_buffer
      ! const VkCommandBufferBeginInfo *
      type(c_ptr), intent(in), value :: p_begin_info
      integer(c_int32_t) :: vk_result
    end function vk_begin_command_buffer


    subroutine vk_cmd_begin_render_pass(command_buffer, p_render_pass_begin, contents) bind(c, name = "vkCmdBeginRenderPass")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_command_buffer), intent(in), value :: command_buffer
      ! const VkRenderPassBeginInfo *
      type(c_ptr), intent(in), value :: p_render_pass_begin
      ! VkSubpassContents
      integer(c_int32_t), intent(in), value :: contents
    end subroutine vk_cmd_begin_render_pass


    subroutine vk_cmd_bind_pipeline(command_buffer, pipeline_bind_point, pipeline) bind(c, name = "vkCmdBindPipeline")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_command_buffer), intent(in), value :: command_buffer
      ! VkPipelineBindPoint
      integer(c_int32_t), intent(in), value :: pipeline_bind_point
      type(vk_pipeline), intent(in), value :: pipeline
    end subroutine vk_cmd_bind_pipeline


    subroutine vk_cmd_set_viewport(command_buffer, first_viewport, viewport_count, p_viewports) bind(c, name = "vkCmdSetViewport")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_command_buffer), intent(in), value :: command_buffer
      ! uint32_t
      integer(c_int32_t), intent(in), value :: first_viewport
      ! uint32_t
      integer(c_int32_t), intent(in), value :: viewport_count
      ! const VkViewport *
      type(c_ptr), intent(in), value :: p_viewports
    end subroutine vk_cmd_set_viewport


    subroutine vk_cmd_set_scissor(command_buffer, first_scissor, scissor_count, p_scissors) bind(c, name = "vkCmdSetScissor")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_command_buffer), intent(in), value :: command_buffer
      ! uint32_t
      integer(c_int32_t), intent(in), value :: first_scissor
      ! uint32_t
      integer(c_int32_t), intent(in), value :: scissor_count
      ! const VkRect2D *
      type(c_ptr), intent(in), value :: p_scissors
    end subroutine vk_cmd_set_scissor


    subroutine vk_cmd_draw(command_buffer, vertex_count, instance_count, first_vertex, first_instance) bind(c, name = "vkCmdDraw")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_command_buffer), intent(in), value :: command_buffer
      ! uint32
      integer(c_int32_t), intent(in), value :: vertex_count
      ! uint32
      integer(c_int32_t), intent(in), value :: instance_count
      ! uint32
      integer(c_int32_t), intent(in), value :: first_vertex
      ! uint32
      integer(c_int32_t), intent(in), value :: first_instance
    end subroutine vk_cmd_draw


    subroutine vk_cmd_end_render_pass(command_buffer) bind(c, name = "vkCmdEndRenderPass")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_command_buffer), intent(in), value :: command_buffer
    end subroutine vk_cmd_end_render_pass


    function vk_end_command_buffer(command_buffer) result(vk_result) bind(c, name = "vkEndCommandBuffer")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_command_buffer), intent(in), value :: command_buffer
      integer(c_int32_t) :: vk_result
    end function vk_end_command_buffer


    function vk_create_semaphore(logical_device, p_create_info, p_allocator, p_semaphore) result(vk_result) bind(c, name = "vkCreateSemaphore")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkSemaphoreCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_semaphore), intent(in) :: p_semaphore
      integer(c_int32_t) :: vk_result
    end function vk_create_semaphore


    function vk_create_fence(logical_device, p_create_info, p_allocator, p_fence) result(vk_result) bind(c, name = "vkCreateFence")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! const VkFenceCreateInfo *
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
      type(vk_fence), intent(inout) :: p_fence
      integer(c_int32_t) :: vk_result
    end function vk_create_fence


    subroutine vk_destroy_semaphore(logical_device, semaphore, p_allocator) bind(c, name = "vkDestroySemaphore")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_semaphore), intent(in), value :: semaphore
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_semaphore


    subroutine vk_destroy_fence(logical_device, fence, p_allocator) bind(c, name = "vkDestroyFence")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_fence), intent(in), value :: fence
      ! const VkAllocationCallbacks *
      type(c_ptr), intent(in), value :: p_allocator
    end subroutine vk_destroy_fence


    function vk_wait_for_fences(logical_device, fence_count, p_fences, wait_all, timeout) result(vk_result) bind(c, name = "vkWaitForFences")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! uint32_t
      integer(c_int32_t), intent(in), value :: fence_count
      ! const VkFence *
      type(c_ptr), intent(in), value :: p_fences
      ! VkBool32
      integer(c_int32_t), intent(in), value :: wait_all
      ! uint64_t
      integer(c_int64_t), intent(in), value :: timeout
      integer(c_int32_t) :: vk_result
    end function vk_wait_for_fences


    function vk_reset_fences(logical_device, fence_count, p_fences) result(vk_result) bind(c, name = "vkResetFences")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      ! uint32_t
      integer(c_int32_t), intent(in), value :: fence_count
      ! const VkFence *
      type(c_ptr), intent(in), value :: p_fences
      integer(c_int32_t) :: vk_result
    end function vk_reset_fences


    function vk_acquire_next_image_khr(logical_device, swapchain, timeout, semaphore, fence, p_image_index) result(vk_result) bind(c, name = "vkAcquireNextImageKHR")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      type(vk_swapchain_khr), intent(in), value :: swapchain
      ! uint64_t
      integer(c_int64_t), intent(in), value :: timeout
      type(vk_semaphore), intent(in), value :: semaphore
      type(vk_fence), intent(in), value :: fence
      ! uint32_t *
      integer(c_int32_t), intent(inout) :: p_image_index
      integer(c_int32_t) :: vk_result
    end function vk_acquire_next_image_khr


    function vk_reset_command_buffer(command_buffer, flags) result(vk_result) bind(c, name = "vkResetCommandBuffer")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_command_buffer), intent(in), value :: command_buffer
      ! VkCommandBufferResetFlags
      integer(c_int32_t), intent(in), value :: flags
      integer(c_int32_t) :: vk_result
    end function vk_reset_command_buffer


    function vk_queue_submit(queue, submit_count, p_submits, fence) result(vk_result) bind(c, name = "vkQueueSubmit")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_queue), intent(in), value :: queue
      ! uint32_t
      integer(c_int32_t), intent(in), value :: submit_count
      ! const VkSubmitInfo *
      type(c_ptr), intent(in), value :: p_submits
      type(vk_fence), intent(in), value :: fence
      integer(c_int32_t) :: vk_result
    end function vk_queue_submit


    function vk_queue_present_khr(queue, p_present_info) result(vk_result) bind(c, name = "vkQueuePresentKHR")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_queue), intent(in), value :: queue
      ! const VkPresentInfoKHR *
      type(c_ptr), intent(in), value :: p_present_info
      integer(c_int32_t) :: vk_result
    end function vk_queue_present_khr


    function vk_device_wait_idle(logical_device) result(vk_result) bind(c, name = "vkDeviceWaitIdle")
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_device), intent(in), value :: logical_device
      integer(c_int32_t) :: vk_result
    end function


    ! todo: marker for end of functions.

!? FUNCTION BLUEPRINTS. ============================================================


    function pfn_vk_create_debug_utils_messenger_ext(instance, p_create_info, p_allocator, p_messenger) result(vk_result) bind(c)
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_instance), intent(in), value :: instance
      ! const VkDebugUtilsMessengerCreateInfoEXT*
      type(c_ptr), intent(in), value :: p_create_info
      ! const VkAllocationCallbacks *
      type(c_funptr), intent(in), value :: p_allocator
      type(vk_debug_utils_messenger_ext), intent(inout) :: p_messenger
      integer(c_int32_t) :: vk_result
    end function pfn_vk_create_debug_utils_messenger_ext


    subroutine pfn_vk_destroy_debug_utils_messenger_ext(instance, messenger, p_allocator) bind(c)
      use, intrinsic :: iso_c_binding
      use :: forvulkan_types
      implicit none

      type(vk_instance), intent(in), value :: instance
      type(vk_debug_utils_messenger_ext), intent(in), value :: messenger
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

    type(vk_instance), intent(in), value :: instance
    ! const VkDebugUtilsMessengerCreateInfoEXT *
    type(c_ptr), intent(in), value :: p_create_info
    ! const VkAllocationCallbacks *
    type(c_funptr), intent(in), value :: p_allocator
    type(vk_debug_utils_messenger_ext), intent(inout) :: p_debug_messenger
    integer(c_int32_t) :: vk_result
    character(len = :, kind = c_char), pointer :: function_name
    type(c_funptr) :: function_pointer
    procedure(pfn_vk_create_debug_utils_messenger_ext), pointer :: func

    ! We're asking Vulkan for the function pointer for debug info here.
    allocate(character(len = 31, kind = c_char) :: function_name)
    function_name = "vkCreateDebugUtilsMessengerEXT"//achar(0)

    function_pointer = vk_get_instance_proc_addr(instance, c_loc(function_name))

    deallocate(function_name)

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

    type(vk_instance), intent(in), value :: instance
    type(vk_debug_utils_messenger_ext), intent(in), value :: debug_messenger
    ! const VkAllocationCallbacks *
    type(c_funptr), intent(in), value :: p_allocator
    character(len = :, kind = c_char), pointer :: function_name
    type(c_funptr) :: function_pointer
    procedure(pfn_vk_destroy_debug_utils_messenger_ext), pointer :: func

    ! We're asking Vulkan for the function pointer for debug info here.
    allocate(character(len = 32, kind = c_char) :: function_name)
    function_name = "vkDestroyDebugUtilsMessengerEXT"//achar(0)

    function_pointer = vk_get_instance_proc_addr(instance, c_loc(function_name))

    deallocate(function_name)

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
