module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: string_f90
  use :: vector
  use :: forvulkan
  use :: vector_3f
  use :: vector_2f
  ! !? These are imported in the order of the steps this takes.
  ! use :: vulkan_driver_ensure_validation_layers
  ! use :: vulkan_driver_create_instance
  ! use :: vulkan_driver_create_debug_messenger
  ! use :: vulkan_driver_create_surface
  ! use :: vulkan_driver_select_physical_device
  ! use :: vulkan_driver_create_logical_device
  ! use :: vulkan_driver_create_swapchain
  ! use :: vulkan_driver_create_image_views
  ! use :: vulkan_driver_create_render_pass
  ! use :: vulkan_driver_create_graphics_pipeline
  ! use :: vulkan_driver_create_framebuffers
  ! use :: vulkan_driver_create_command_pool
  ! use :: vulkan_driver_create_command_buffer
  ! use :: vulkan_driver_create_sync_objects
  ! !? Then after this, it's just helpers.
  ! use :: vulkan_driver_record_command_buffer
  ! use :: vulkan_driver_draw_frame
  ! use :: vulkan_driver_clean_up_swapchain
  ! use :: vulkan_driver_create_vertex_buffer
  ! use :: vulkan_driver_create_index_buffer
  ! use :: vulkan_driver_create_uniform_buffers
  ! use :: vulkan_driver_create_descriptor_pool
  ! use :: vulkan_driver_create_descriptor_sets
  ! !! THIS IS TEMPORARY
  ! use :: vulkan_vertex
  ! use :: vulkan_driver_uniform_buffer
  ! use :: vulkan_driver_create_descriptor_set_layout
  implicit none

  ! https://github.com/KhronosGroup/Vulkan-Headers/blob/main/include/vulkan/vulkan_core.h

  ! Treating this thing as a class to follow the vulkan tutorial.
  ! todo: in formine this will have a pointer struct which inherits from a base class, to direct traffic flow to these functions.

  type :: vk_driver
    type(vk_instance) :: vulkan_instance
    type(vk_debug_utils_messenger_ext) :: debug_messenger
    type(vk_surface_khr) :: window_surface
    type(vk_physical_device) :: physical_device
    type(vk_device) :: logical_device
    type(vk_queue) :: graphics_queue
    type(vk_queue) :: present_queue
    type(vk_swapchain_khr) :: swapchain
    ! Vk Image Vector
    type(vec) :: swapchain_images
    type(vk_format) :: swapchain_image_format
    type(vk_extent_2d) :: swapchain_extent
    ! Vk ImageView Vector
    type(vec) :: swapchain_image_views
    type(vk_shader_module) :: vertex_shader_module
    type(vk_shader_module) :: fragment_shader_module
    type(vk_descriptor_set_layout) :: descriptor_set_layout
    type(vk_pipeline_layout) :: pipeline_layout
    type(vk_render_pass) :: render_pass
    type(vk_pipeline) :: graphics_pipeline
    ! Vk Framebuffer Vector
    type(vec) :: swapchain_framebuffers
    type(vk_command_pool) :: command_pool
    ! Vk CommandBuffer Vector
    type(vec) :: command_buffers
    ! Vk Semaphore Vector
    type(vec) :: image_available_semaphores
    ! Vk Semaphore Vector
    type(vec) :: render_finished_semaphores
    ! Vk Fence Vector
    type(vec) :: in_flight_fences
    type(vk_descriptor_pool) :: descriptor_pool
    ! Vk DescriptorSet Vector
    type(vec) :: descriptor_sets
    !? This is the frame we're currently on.
    integer(c_int64_t) :: current_frame = 1
    !? How many frames should be processed concurrently.
    ! todo: make this hidden with private
    integer(c_int64_t) :: MAX_FRAMES_IN_FLIGHT = 2
    !! This part is temporary.
    type(vk_buffer) :: vertex_buffer
    type(vk_device_memory) :: vertex_buffer_memory
    type(vk_buffer) :: index_buffer
    type(vk_device_memory) :: index_buffer_memory
    integer(c_int32_t) :: indices_size
    !! End temporary.
    !? This is the storage for the uniform buffer data.
    ! Vk Buffer Vector
    type(vec) :: uniform_buffers
    ! Vk DeviceMemory Vector
    type(vec) :: uniform_buffers_memory
    ! void * Vector (Vector of raw pointers to [currently] uniform_buffer_object)
    type(vec) :: uniform_buffers_mapped
    logical(c_bool) :: framebuffer_resized = .false.
    ! Controls debugging output. ! todo: make this hidden with private
    logical(c_bool) :: DEBUG_MODE = .true.
  contains
    procedure :: init => vk_driver_init
    !! fixme: this is temporary!
    procedure :: main => vk_driver_main_loop
    procedure :: create_glfw => vk_driver_create_glfw
    procedure :: destroy => vk_driver_destroy
    procedure :: ensure_extensions_present => vk_driver_ensure_extensions_present
    procedure :: create_required_extensions => vk_driver_create_required_extensions
    procedure :: create_vulkan_instance => vk_driver_create_vulkan_instance
    procedure :: create_vulkan_instance_create_info => vk_driver_create_vulkan_instance_create_info
    procedure :: create_required_validation_layers => vk_driver_create_required_validation_layers
    procedure :: create_debug_messenger_struct => vk_driver_create_debug_messenger_struct
    procedure :: create_app_info => vk_driver_create_app_info
  end type vk_driver


  !! TODO: This stuff should probably be part of the type

  ! This is a trick to pass the mutable boolean to the framebuffer resize callback.
  type(c_ptr) :: resized_loc


contains


!? This is how to get from these vectors. (char ** array underneath)
!? do i = 1,int(validation_layers%size())
!! NOTICE: Redirecting the pointer with c_f_pointer here!
!?   call c_f_pointer(validation_layers%get(int(i, c_int64_t)), raw_c_ptr_ptr)
!?   required_layer => string_from_c(raw_c_ptr_ptr)
!?   print*,required_layer
!? end do


!* INITIALIZATION. ====================================================================


  subroutine vk_driver_init(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! type(vertex), dimension(4) :: vertices
    ! integer(c_int32_t), dimension(6) :: indices

    ! vertices(1) = vertex(vec2f(-0.5, -0.5), vec3f(1.0, 0.0, 0.0))
    ! vertices(2) = vertex(vec2f(0.5,  -0.5), vec3f(0.0, 1.0, 0.0))
    ! vertices(3) = vertex(vec2f(0.5,   0.5), vec3f(0.0, 0.0, 1.0))
    ! vertices(4) = vertex(vec2f(-0.5,  0.5), vec3f(1.0, 1.0, 1.0))

    ! indices = [0,1,2,2,3,0]

    ! indices_size = size(indices)

    ! call create_glfw(framebuffer_resized, 800, 600)

    ! call ensure_extensions_present(DEBUG_MODE)

    ! call ensure_validation_layer_support(DEBUG_MODE)

    ! call create_vulkan_instance(vulkan_instance, DEBUG_MODE)

    ! call setup_debug_messenger(vulkan_instance, debug_messenger, DEBUG_MODE)

    ! call create_surface(vulkan_instance, window_surface)

    ! call select_physical_device(vulkan_instance, physical_device, window_surface)

    ! call create_logical_device(physical_device, logical_device, graphics_queue, present_queue, window_surface, DEBUG_MODE)

    ! call create_swapchain(physical_device, logical_device, window_surface, swapchain, swapchain_images, swapchain_image_format, swapchain_extent)

    ! call create_image_views(logical_device, swapchain_images, swapchain_image_views, swapchain_image_format)

    ! call create_render_pass(logical_device, render_pass, swapchain_image_format)

    ! call create_descriptor_set_layout(logical_device, descriptor_set_layout)

    ! call create_graphics_pipeline(logical_device, vertex_shader_module, fragment_shader_module, swapchain_extent, pipeline_layout, render_pass, graphics_pipeline, descriptor_set_layout)

    ! call create_framebuffers(logical_device, swapchain_framebuffers, swapchain_image_views, render_pass, swapchain_extent)

    ! call create_command_pool(physical_device, window_surface, logical_device, command_pool)

    ! call create_vertex_buffer(physical_device, logical_device, vertices, vertex_buffer, vertex_buffer_memory, command_pool, graphics_queue)

    ! call create_index_buffer(physical_device, logical_device, indices, index_buffer, index_buffer_memory, command_pool, graphics_queue)

    ! call create_uniform_buffers(physical_device, logical_device, MAX_FRAMES_IN_FLIGHT, uniform_buffers, uniform_buffers_memory, uniform_buffers_mapped)

    ! call create_descriptor_pool(logical_device, descriptor_pool, MAX_FRAMES_IN_FLIGHT)

    ! call create_descriptor_sets(logical_device, descriptor_sets, descriptor_set_layout, descriptor_pool, MAX_FRAMES_IN_FLIGHT, uniform_buffers)

    ! call create_command_buffers(logical_device, MAX_FRAMES_IN_FLIGHT, command_pool, command_buffers)

    ! call create_sync_objects(logical_device, MAX_FRAMES_IN_FLIGHT, image_available_semaphores, render_finished_semaphores, in_flight_fences)
  end subroutine vk_driver_init



!* MAIN LOOP. ====================================================================


  subroutine vk_driver_main_loop(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! integer(c_int32_t) :: a

    ! a = 0

    ! do while(.not. glfw_window_should_close())
    !   call glfw_poll_events()
    !   call draw_frame(logical_device, current_frame, MAX_FRAMES_IN_FLIGHT, in_flight_fences, image_available_semaphores, render_finished_semaphores, swapchain, command_buffers, render_pass, swapchain_framebuffers, swapchain_extent, graphics_pipeline, graphics_queue, present_queue, physical_device, window_surface, swapchain_images, swapchain_image_format, swapchain_image_views, framebuffer_resized, vertex_buffer, index_buffer, indices_size, uniform_buffers_mapped, descriptor_sets, pipeline_layout)

    !   if (a >= 100) then
    !     ! call glfw_close_window()
    !   end if

    !   a = a + 1
    ! end do

    ! if (vk_device_wait_idle(logical_device) /= VK_SUCCESS) then
    !   error stop "[Vulkan] Error: Failed to wait idle on logical device."
    ! end if
  end subroutine vk_driver_main_loop


!* CLEAN UP. ====================================================================


  subroutine vk_driver_destroy(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int64_t) :: i
    type(vk_semaphore), pointer :: semaphore_pointer
    type(vk_fence), pointer :: fence_pointer
    type(vk_buffer), pointer :: uniform_buffer_pointer
    type(vk_device_memory), pointer :: uniform_buffer_memory_pointer

    call clean_up_swapchain(this%logical_device, this%swapchain_framebuffers, this%swapchain_image_views, this%swapchain)

    do i = 1,this%MAX_FRAMES_IN_FLIGHT
      call c_f_pointer(this%uniform_buffers%get(i), uniform_buffer_pointer)
      call vk_destroy_buffer(this%logical_device, uniform_buffer_pointer, c_null_ptr)

      call c_f_pointer(this%uniform_buffers_memory%get(i), uniform_buffer_memory_pointer)
      call vk_free_memory(this%logical_device, uniform_buffer_memory_pointer, c_null_ptr)
    end do

    call vk_destroy_descriptor_pool(this%logical_device, this%descriptor_pool, c_null_ptr)

    call vk_destroy_descriptor_set_layout(this%logical_device, this%descriptor_set_layout, c_null_ptr)

    call vk_destroy_buffer(this%logical_device, this%index_buffer, c_null_ptr)
    call vk_free_memory(this%logical_device, this%index_buffer_memory, c_null_ptr)

    call vk_destroy_buffer(this%logical_device, this%vertex_buffer, c_null_ptr)
    call vk_free_memory(this%logical_device, this%vertex_buffer_memory, c_null_ptr)

    do i = 1,this%MAX_FRAMES_IN_FLIGHT
      call c_f_pointer(this%image_available_semaphores%get(i), semaphore_pointer)
      call vk_destroy_semaphore(this%logical_device, semaphore_pointer, c_null_ptr)

      call c_f_pointer(this%render_finished_semaphores%get(i), semaphore_pointer)
      call vk_destroy_semaphore(this%logical_device, semaphore_pointer, c_null_ptr)

      call c_f_pointer(this%in_flight_fences%get(i), fence_pointer)
      call vk_destroy_fence(this%logical_device, fence_pointer, c_null_ptr)
    end do

    call vk_destroy_command_pool(this%logical_device, this%command_pool, c_null_ptr)

    call vk_destroy_pipeline(this%logical_device, this%graphics_pipeline, c_null_ptr)

    call vk_destroy_pipeline_layout(this%logical_device, this%pipeline_layout, c_null_ptr)

    call vk_destroy_render_pass(this%logical_device, this%render_pass, c_null_ptr)

    call vk_destroy_surface_khr(this%vulkan_instance, this%window_surface, c_null_ptr)

    call vk_destroy_device(this%logical_device, c_null_ptr)

    if (this%DEBUG_MODE) then
      call forvulkan_destroy_debug_utils_messenger_ext(this%vulkan_instance, this%debug_messenger, c_null_ptr)
    end if

    print"(A)","[Vulkan]: Destroying instance."

    call vk_destroy_instance(this%vulkan_instance, c_null_ptr)

    call glfw_destroy_window()

    call glfw_terminate()

  end subroutine vk_driver_destroy


!* DERIVED TYPE IMPLEMENTATION. ====================================================================


  !! If you value your sanity do not scroll any further down.
  !? If you value your sanity do not scroll any further down.
  !* If you value your sanity do not scroll any further down.

  ! I tried to group things together. Like the callback init and the callback, etc.


  subroutine vk_driver_create_glfw(this, window_width, window_height)
    implicit none

    class(vk_driver), intent(inout), target :: this
    integer(c_int32_t), intent(in), value :: window_width, window_height

    if (.not. glfw_init()) then
      error stop "[Vulkan] Error: Failed to initialize GLFW."
    end if

    resized_loc = c_loc(this%framebuffer_resized)

    call glfw_window_hint(GLFW_SCALE_FRAMEBUFFER, GLFW_TRUE)
    call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)
    call glfw_window_hint(GLFW_RESIZABLE, GLFW_TRUE)

    if (.not. glfw_create_window(window_width, window_height, "forvulkan")) then
      error stop "[Vulkan]: Failed to create window."
    end if

    call glfw_set_framebuffer_size_callback(c_funloc(vk_driver_framebuffer_size_callback))
  end subroutine vk_driver_create_glfw


  recursive subroutine vk_driver_framebuffer_size_callback(window, width, height) bind(c)
    implicit none

    type(c_ptr), intent(in), value :: window
    integer(c_int32_t), intent(in), value :: width, height
    logical(c_bool), pointer :: framebuffer_resized_pointer

    if (.false.) then
      print*,window, width, height
    end if

    call c_f_pointer(resized_loc, framebuffer_resized_pointer)
    framebuffer_resized_pointer = .true.
  end subroutine vk_driver_framebuffer_size_callback


  subroutine vk_driver_ensure_extensions_present(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vec) :: required_extensions
    integer(c_int) :: result, extension_count
    type(vec) :: available_extensions
    type(vk_extension_properties) :: blank
    integer(c_int) :: i, j
    type(c_ptr), pointer :: raw_c_ptr_ptr
    type(vk_extension_properties), pointer :: extension_properties
    character(len = :, kind = c_char), pointer :: temp_string_pointer
    character(len = :, kind = c_char), pointer :: temp
    logical(c_bool) :: found

    print"(A)","[Vulkan]: Gathering available extensions."

    call this%create_required_extensions(required_extensions)

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, c_null_ptr)

    if (result /= VK_SUCCESS) then
      error stop "[Vulkan]: Failed to enumrate instance extension properties. Error code ["//int_to_string(result)//"]"
    end if

    available_extensions = new_vec(sizeof(blank), int(extension_count, c_int64_t))
    call available_extensions%resize(int(extension_count, c_int64_t), blank)

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, available_extensions%get(1_8))

    print"(A)","[Vulkan]: Ensuring required extensions are present."

    ! Iterate all required extensions.

    do j = 1,int(required_extensions%size())

      found = .false.

      call c_f_pointer(required_extensions%get(int(j, c_int64_t)), raw_c_ptr_ptr)
      temp_string_pointer => string_from_c(raw_c_ptr_ptr)

      ! Iterate all available extensions.
      do i = 1,int(extension_count)

        ! Transfer the VkExtensionProperties pointer into Fortran.
        call c_f_pointer(available_extensions%get(int(i, c_int64_t)), extension_properties)

        ! Let us convert the extension name from a char array into a string.
        temp => character_array_to_string_pointer(extension_properties%extension_name)

        ! And check if the strings are equal.
        if (temp_string_pointer == temp) then
          found = .true.
          deallocate(temp)
          exit
        end if

        deallocate(temp)
      end do

      ! We can't continue if a required extensions isn't present.
      if (found) then
        print"(A)","[Vulkan]: Found required extension ["//temp_string_pointer//"]"
      else
        error stop "[Vulkan] Error: Could not find required extension ["//temp_string_pointer//"]"
      end if
    end do

    call available_extensions%destroy()
    call required_extensions%destroy()

    print"(A)","[Vulkan]: All required extensions are present."
  end subroutine vk_driver_ensure_extensions_present


  subroutine vk_driver_create_required_extensions(this, required_extensions)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vec), intent(inout) :: required_extensions
    integer(c_int) :: glfw_extension_count
    type(c_ptr) :: c_glfw_extension_array_pointer
    character(len = :, kind = c_char), pointer :: temp, output
    type(c_ptr), dimension(:), pointer :: c_extension_name_pointer_array
    integer(c_int) :: i
    ! type(c_ptr), pointer :: raw_c_ptr

    print"(A)","[Vulkan]: Gathering required GLFW extensions."

    c_glfw_extension_array_pointer = glfw_get_required_instance_extensions(glfw_extension_count)

    ! Grabble the extension string pointers from C.
    temp => null()
    required_extensions = new_vec(sizeof(c_null_ptr), 0_8, required_extensions_vec_gc)

    call c_f_pointer(c_glfw_extension_array_pointer, c_extension_name_pointer_array, [glfw_extension_count])

    ! Shove all those char pointers into the vector's heap.
    do i = 1,glfw_extension_count
      temp => string_from_c(c_extension_name_pointer_array(i))
      allocate(character(len = len(temp)+1, kind = c_char) :: output)
      output = temp//achar(0)

      call required_extensions%push_back(c_loc(output))
    end do

    print"(A)","[Vulkan]: Creating required GLFW extensions."

    ! We need this for it to work in MoltenVK.
    allocate(character(len = len(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME), kind = c_char) :: output)
    output = VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME
    call required_extensions%push_back(c_loc(output))

    ! We need this for debug messaging in debug mode.

    if (this%DEBUG_MODE) then
      allocate(character(len = len(VK_EXT_DEBUG_UTILS_EXTENSION_NAME), kind = c_char) :: output)
      output = VK_EXT_DEBUG_UTILS_EXTENSION_NAME
      call required_extensions%push_back(c_loc(output))
    end if
  end subroutine vk_driver_create_required_extensions


  subroutine required_extensions_vec_gc(raw_c_ptr_ptr)
    implicit none

    type(c_ptr), intent(in), value :: raw_c_ptr_ptr
    type(c_ptr), pointer :: raw_c_ptr
    character(len = :, kind = c_char), pointer :: str

    call c_f_pointer(raw_c_ptr_ptr, raw_c_ptr)
    str => string_from_c(raw_c_ptr)

    deallocate(str)
  end subroutine required_extensions_vec_gc


  subroutine vk_driver_create_vulkan_instance(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! VkInstanceCreateInfo
    type(vk_instance_create_info), target :: vulkan_create_info
    ! VkApplicationInfo
    type(vk_application_info), target :: app_info
    type(vk_debug_utils_messenger_create_info_ext) :: before_init_messenger_create_info
    integer(c_int) :: result
    type(vec) :: required_extensions
    type(vec) :: required_validation_layers
    character(len = :, kind = c_char), pointer :: app_name, engine_name

    allocate(character(len = 10, kind = c_char) :: app_name)
    app_name = "ForVulkan"//achar(0)
    allocate(character(len = 8, kind = c_char) :: engine_name)
    engine_name = "Formine"//achar(0)

    call this%create_app_info(app_info, app_name, engine_name)

    call this%create_vulkan_instance_create_info(vulkan_create_info, app_info, before_init_messenger_create_info, this%DEBUG_MODE, required_extensions, required_validation_layers)

    print"(A)", "[Vulkan]: Creating instance."

    result = vk_create_instance(c_loc(vulkan_create_info), c_null_ptr, this%vulkan_instance)

    if (result /= VK_SUCCESS) then
      ! Shove driver check in.
      if (result == VK_ERROR_INCOMPATIBLE_DRIVER) then
        error stop "[Vulkan] Error: Failed to create Vulkan instance. Incompatible driver. Error code: ["//int_to_string(result)//"]"
      end if
      error stop "[Vulkan] Error: Failed to create Vulkan instance. Error code: ["//int_to_string(result)//"]"
    end if

    deallocate(app_name)
    deallocate(engine_name)
    call required_extensions%destroy()
    call required_validation_layers%destroy()
  end subroutine vk_driver_create_vulkan_instance


  subroutine vk_driver_create_vulkan_instance_create_info(this, vulkan_create_info, app_info, before_init_messenger_create_info, DEBUG_MODE, required_extensions, required_validation_layers)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_instance_create_info), intent(inout) :: vulkan_create_info
    type(vk_application_info), intent(in), target :: app_info
    type(vk_debug_utils_messenger_create_info_ext), intent(inout), target :: before_init_messenger_create_info
    logical(c_bool), intent(in), value :: DEBUG_MODE
    type(vec), intent(inout) :: required_extensions
    type(vec), intent(inout) :: required_validation_layers

    print"(A)","[Vulkan]: Creating create info."

    call this%create_required_extensions(required_extensions)
    call this%create_required_validation_layers(required_validation_layers)

    vulkan_create_info%flags = or(vulkan_create_info%flags, VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR)

    vulkan_create_info%s_type = VK_STRUCTURE_TYPE%INSTANCE_CREATE_INFO
    vulkan_create_info%p_application_info = c_loc(app_info)

    vulkan_create_info%enabled_extension_count = int(required_extensions%size())
    !? Note: This basically turns the vector into a pointer array.
    vulkan_create_info%pp_enabled_extension_names = required_extensions%get(1_8)

    if (DEBUG_MODE) then
      ! Passing the underlying char** array in.
      vulkan_create_info%enabled_layer_count = int(required_validation_layers%size())
      vulkan_create_info%pp_enabled_layer_names = required_validation_layers%get(1_8)

      call this%create_debug_messenger_struct(before_init_messenger_create_info, DEBUG_MODE)
      vulkan_create_info%p_next = c_loc(before_init_messenger_create_info)
    else
      vulkan_create_info%enabled_layer_count = 0
    end if
  end subroutine vk_driver_create_vulkan_instance_create_info


  subroutine vk_driver_create_required_validation_layers(this, required_validation_layers)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! const char *
    type(vec), intent(inout) :: required_validation_layers
    character(len = :, kind = c_char), pointer :: layer_name

    ! If we're not in debug mode, don't bother with this.
    if (.not. this%DEBUG_MODE) then
      return
    end if

    ! Create validation layers that we need.

    print"(A)","[Vulkan]: Creating required validation layers."

    layer_name => null()
    required_validation_layers = new_vec(sizeof(c_null_ptr), 0_8, validation_layers_vector_gc)

    allocate(character(len = 28, kind = c_char) :: layer_name)
    layer_name = "VK_LAYER_KHRONOS_validation"//achar(0)
    call required_validation_layers%push_back(c_loc(layer_name))
  end subroutine vk_driver_create_required_validation_layers


  subroutine validation_layers_vector_gc(raw_c_ptr_ptr)
    implicit none

    type(c_ptr), intent(in), value :: raw_c_ptr_ptr
    type(c_ptr), pointer :: raw_c_ptr
    character(len = :, kind = c_char), pointer :: str

    call c_f_pointer(raw_c_ptr_ptr, raw_c_ptr)
    str => string_from_c(raw_c_ptr)

    deallocate(str)
  end subroutine validation_layers_vector_gc


  subroutine vk_driver_create_debug_messenger_struct(this, messenger_create_info, DEBUG_MODE)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_debug_utils_messenger_create_info_ext), intent(inout) :: messenger_create_info
    logical(c_bool), intent(in), value :: DEBUG_MODE

    if (.not. DEBUG_MODE) then
      return
    end if

    messenger_create_info%s_type = VK_STRUCTURE_TYPE%DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
    messenger_create_info%message_severity = or(VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT, or(VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT, VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT))
    messenger_create_info%message_type = or(VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT, or(VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT, VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT))
    messenger_create_info%pfn_user_callback = c_funloc(debug_callback)
    messenger_create_info%p_user_data = c_null_ptr ! Optional.
  end subroutine vk_driver_create_debug_messenger_struct


  ! This is the debug output.
  recursive function debug_callback(message_severity, message_type, p_callback_data_ptr) result(vk_bool_32) bind(c)
    implicit none

    integer(c_int), intent(in), value :: message_severity, message_type
    ! const VkDebugUtilsMessengerCallbackDataEXT *
    type(c_ptr), intent(in), value :: p_callback_data_ptr
    integer(c_int) :: vk_bool_32
    type(vk_debug_utils_messenger_callback_data_ext), pointer :: p_callback_data

    if (.false.) then
      print*,message_severity, message_type
    end if

    call c_f_pointer(p_callback_data_ptr, p_callback_data)

    if (message_severity >= VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT) then
      ! Message is important enough to show
      ! print*,"high severity"
      error stop achar(10)//"===========================|"//achar(10)//"[Vulkan] Validation layer: |"//achar(10)//"===========================|"//achar(10)//string_from_c(p_callback_data%p_message)//achar(10)//"=========================="
    end if

    vk_bool_32 = VK_FALSE
  end function debug_callback


  subroutine vk_driver_create_app_info(this, app_info, app_name, engine_name)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_application_info), intent(inout) :: app_info
    character(len = :, kind = c_char), intent(in), pointer :: app_name, engine_name

    print"(A)","[Vulkan]: Creating app info."

    app_info%s_type = VK_STRUCTURE_TYPE%APPLICATION_INFO

    app_info%p_application_name = c_loc(app_name)
    app_info%application_version = vk_make_api_version(0,1,0,0)
    app_info%p_engine_name = c_loc(engine_name)
    app_info%engine_version = vk_make_api_version(0,1,0,0)
    app_info%api_version = VK_API_VERSION_1_0
  end subroutine vk_driver_create_app_info

end module vulkan_driver
