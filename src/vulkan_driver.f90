module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: string_f90
  use :: vector
  use :: forvulkan
  use :: vector_3f
  use :: vector_2f
  use :: integer32_set

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
    procedure :: clean_up_swapchain => vk_driver_clean_up_swapchain
    procedure :: ensure_validation_layer_support => vk_driver_ensure_validation_layer_support
    procedure :: setup_debug_messenger => vk_driver_setup_debug_messenger
    procedure :: create_surface => vk_driver_create_surface
    procedure :: select_physical_device => vk_driver_select_physical_device
    procedure :: device_is_suitable => vk_driver_device_is_suitable
    procedure :: check_device_extension_support => vk_driver_check_device_extension_support
    procedure :: create_required_physical_device_extensions => vk_driver_create_required_physical_device_extensions
    procedure :: find_queue_families => vk_driver_find_queue_families
    procedure :: create_logical_device => vk_driver_create_logical_device
    procedure :: query_swapchain_support => vk_driver_query_swapchain_support
    procedure :: create_swapchain => vk_driver_create_swapchain
    procedure :: create_image_views => vk_driver_create_image_views
    procedure :: create_render_pass => vk_driver_create_render_pass
    procedure :: create_descriptor_set_layout => vk_driver_create_descriptor_set_layout
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
    ! This will go out of scope at the end of the init.
    type(vk_debug_utils_messenger_ext) :: debug_messenger
    ! type(vertex), dimension(4) :: vertices
    ! integer(c_int32_t), dimension(6) :: indices

    ! vertices(1) = vertex(vec2f(-0.5, -0.5), vec3f(1.0, 0.0, 0.0))
    ! vertices(2) = vertex(vec2f(0.5,  -0.5), vec3f(0.0, 1.0, 0.0))
    ! vertices(3) = vertex(vec2f(0.5,   0.5), vec3f(0.0, 0.0, 1.0))
    ! vertices(4) = vertex(vec2f(-0.5,  0.5), vec3f(1.0, 1.0, 1.0))

    ! indices = [0,1,2,2,3,0]

    ! indices_size = size(indices)

    call this%create_glfw(800, 600)

    call this%ensure_extensions_present()

    call this%ensure_validation_layer_support()

    call this%create_vulkan_instance()

    call this%setup_debug_messenger(debug_messenger)

    call this%create_surface()

    call this%select_physical_device()

    call this%create_logical_device()

    call this%create_swapchain()

    call this%create_image_views()

    call this%create_render_pass()

    call this%create_descriptor_set_layout()

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

    call this%clean_up_swapchain()

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

      call this%create_debug_messenger_struct(before_init_messenger_create_info)
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


  subroutine vk_driver_create_debug_messenger_struct(this, messenger_create_info)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_debug_utils_messenger_create_info_ext), intent(inout) :: messenger_create_info

    if (.not. this%DEBUG_MODE) then
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


  subroutine vk_driver_clean_up_swapchain(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int64_t) :: i
    type(vk_framebuffer), pointer :: framebuffer_pointer
    type(vk_image_view), pointer :: image_view_pointer

    do i = 1,this%swapchain_framebuffers%size()
      call c_f_pointer(this%swapchain_framebuffers%get(i), framebuffer_pointer)
      call vk_destroy_framebuffer(this%logical_device, framebuffer_pointer, c_null_ptr)
    end do

    do i = 1,this%swapchain_image_views%size()
      call c_f_pointer(this%swapchain_image_views%get(i), image_view_pointer)
      call vk_destroy_image_view(this%logical_device, image_view_pointer, c_null_ptr)
    end do

    call vk_destroy_swapchain_khr(this%logical_device, this%swapchain, c_null_ptr)
  end subroutine vk_driver_clean_up_swapchain


  subroutine vk_driver_ensure_validation_layer_support(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! const char *
    type(vec) :: required_validation_layers
    ! VkLayerProperties
    type(vec) :: available_layer_array
    type(vk_layer_properties), pointer :: layer
    integer(c_int) :: available_layer_count
    logical(c_bool) :: found
    ! char **
    type(c_ptr), pointer :: raw_c_ptr_ptr
    integer(c_int) :: i, j
    character(len = :, kind = c_char), pointer :: required_layer, temp

    call this%create_required_validation_layers(required_validation_layers)

    ! If we're not in debug mode, don't bother with this.
    if (.not. this%DEBUG_MODE) then
      return
    end if

    print"(A)","[Vulkan]: Checking validation layer support."

    allocate(layer)
    available_layer_array = new_vec(sizeof(layer), 0_8)

    if (vk_enumerate_instance_layer_properties(available_layer_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate instance layer properties."
    end if

    call available_layer_array%resize(int(available_layer_count, c_int64_t), layer)
    deallocate(layer)

    if (available_layer_array%size() == 0) then
      error stop "[Vulkan] Error: No validation layers were found. Is the Vulkan SDK installed?"
    end if

    ! This is sending in the vector as if it were a C array.
    if (vk_enumerate_instance_layer_properties(available_layer_count, available_layer_array%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate instance layer properties."
    end if

    ! Check if we have all required validation layers when running in debug mode.
    do i = 1,int(required_validation_layers%size())

      ! From: Required validation layers.
      call c_f_pointer(required_validation_layers%get(int(i, c_int64_t)), raw_c_ptr_ptr)
      required_layer => string_from_c(raw_c_ptr_ptr)

      found = .false.

      ! Now, let's see if we have this required layer available.
      do j = 1,int(available_layer_array%size())

        call c_f_pointer(available_layer_array%get(int(j, c_int64_t)), layer)

        ! Let us convert the extension name from a char array into a string.
        temp => character_array_to_string_pointer(layer%layer_name)

        ! Check if it's what we need.
        if (required_layer == temp) then
          print"(A)","[Vulkan]: Found required validation layer ["//required_layer//"]"
          found = .true.
          deallocate(temp)
          exit
        end if

        deallocate(temp)
      end do

      ! If we're missing a required validation layer, we literally can't debug.
      if (.not. found) then
        if (required_layer == "VK_LAYER_KHRONOS_validation") then
          error stop "[Vulkan] Error: Did not find required validation layer ["//required_layer//"]. (Is the Vulkan SDK installed?)"
        else
          error stop "[Vulkan] Error: Did not find required validation layer ["//required_layer//"]"
        end if
      end if
    end do

    call available_layer_array%destroy()
    call required_validation_layers%destroy()

    print"(A)","[Vulkan]: Found all required validation layers."
  end subroutine vk_driver_ensure_validation_layer_support


  subroutine vk_driver_setup_debug_messenger(this, debug_messenger)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_debug_utils_messenger_ext), intent(inout) :: debug_messenger
    type(vk_debug_utils_messenger_create_info_ext), target :: debug_messenger_create_info

    ! Don't need this if we're not in debug mode.
    if (.not. this%DEBUG_MODE) then
      return
    end if

    print"(A)","[Vulkan]: Setting up debug messenger."

    call this%create_debug_messenger_struct(debug_messenger_create_info)

    if (forvulkan_create_debug_utils_messenger_ext(this%vulkan_instance, c_loc(debug_messenger_create_info), c_null_ptr, debug_messenger) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to set up debug messenger."
    end if
  end subroutine vk_driver_setup_debug_messenger


  subroutine vk_driver_create_surface(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(c_ptr) :: window_pointer

    window_pointer = glfw_get_window_pointer()

    if (glfw_create_window_surface(this%vulkan_instance, window_pointer, c_null_ptr, this%window_surface) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create window surface."
    end if
  end subroutine vk_driver_create_surface


  ! todo: re-tool this so we can query multiple devices and rank them.
  subroutine vk_driver_select_physical_device(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int32_t) :: device_count, i
    ! c_int64_t [VkPhysicalDevice]
    type(vec) :: available_devices
    type(vk_physical_device), pointer :: physical_device_pointer
    character(len = :, kind = c_char), pointer :: device_name

    print"(A)","[Vulkan]: Selecting physical device."

    ! First, we will get the available devices from Vulkan.
    if (vk_enumerate_physical_devices(this%vulkan_instance, device_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate physical devices."
    end if

    if (device_count == 0) then
      ! todo: in Formine we will make this clean up then run the OpenGL driver. :)
      error stop "[Vulkan] Error: No GPU with Vulkan support available."
    end if

    ! Now, create the vector to store the data.
    available_devices = new_vec(sizeof(this%physical_device), int(device_count, c_int64_t))
    call available_devices%resize(int(device_count, c_int64_t), this%physical_device)

    ! Here we're passing in the underlying C array.
    if (vk_enumerate_physical_devices(this%vulkan_instance, device_count, available_devices%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate physical devices."
    end if

    ! Let's find a device that's suitable.
    device_search: do i = 1,int(available_devices%size())
      ! We're inlining transfering the device pointer from the interal C array into Fortran.
      call c_f_pointer(available_devices%get(int(i, c_int64_t)), physical_device_pointer)

      ! We found it, woo. That's our physical device.
      ! todo: Make a menu option to select another physical device.
      if (this%device_is_suitable(physical_device_pointer, device_name)) then
        this%physical_device = physical_device_pointer
        exit device_search
      end if
    end do device_search

    if (this%physical_device%data == VK_NULL_HANDLE) then
      error stop "[Vulkan] Error: No suitable GPU available."
    else
      ! todo: can put these devices in some kind of array instead of just destroying the pointers.
      print"(A)","[Vulkan]: Using physical device ["//device_name//"]"
      deallocate(device_name)
    end if

    call available_devices%destroy()
  end subroutine vk_driver_select_physical_device


  function vk_driver_device_is_suitable(this, physical_device_pointer, device_name) result(suitable)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_physical_device), intent(inout), pointer :: physical_device_pointer
    character(len = :, kind = c_char), intent(inout), pointer :: device_name
    type(forvulkan_queue_family_indices) :: queue_family_indices
    logical(c_bool) :: suitable
    type(vk_physical_device_properties), pointer :: device_properties
    type(vk_physical_device_features), pointer :: device_features

    suitable = .false.

    allocate(device_properties)
    call vk_get_physical_device_properties(physical_device_pointer, c_loc(device_properties))

    allocate(device_features)
    call vk_get_physical_device_features(physical_device_pointer, c_loc(device_features))

    ! Check if we have the bare minimum to run with.
    ! todo: score GPUs.
    ! todo: device_properties%device_type == VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU .and.
    ! todo: https://vulkan-tutorial.com/Drawing_a_triangle/Setup/Physical_devices_and_queue_families
    ! todo: Base device suitability checks
    ! if (device_features%geometry_shader == VK_TRUE) then
    suitable = .true.
    ! end if

    ! Let us convert the extension name from a char array into a string.
    !! fixme: This is a memory leak when we start checking multiple gpus. :D
    device_name => character_array_to_string_pointer(device_properties%device_name)

    ! Check our queue families.
    queue_family_indices = this%find_queue_families(physical_device_pointer)

    print"(A)","[Vulkan]: Found physical device ["//device_name//"]"

    ! Now, if we have all needed components, we have our physical device!
    if (queue_family_indices%graphics_family_has_value .and. queue_family_indices%present_family_has_value) then
      print"(A)","[Vulkan]: Device has graphical queue family and present support."
    else
      ! No if else, we want to warn about every unsupported queue family.
      if (.not. queue_family_indices%graphics_family_has_value) then
        print"(A)", "[Vulkan]: Device has no graphical queue family."
      end if
      if (.not. queue_family_indices%present_family_has_value) then
        print"(A)", "[Vulkan]: Device has no present queue family."
      end if

      suitable = .false.
    end if

    if (.not. this%check_device_extension_support(physical_device_pointer)) then
      !! FIXME: this needs to list which extension!
      print"(A)", "[Vulkan]: Device is missing extension support."
      suitable = .false.
    end if

    deallocate(device_properties)
    deallocate(device_features)
  end function vk_driver_device_is_suitable


  function vk_driver_check_device_extension_support(this, physical_device) result(has_support)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_physical_device), intent(in), value :: physical_device
    type(forvulkan_swapchain_support_details) :: swapchain_support_details
    logical(c_bool) :: has_support
    integer(c_int32_t) :: extension_count
    ! VkExtensionProperties
    type(vec) :: available_extensions
    ! character(:)
    type(vec) :: required_device_extensions
    type(vk_extension_properties), pointer :: extension_properties
    character(len = :, kind = c_char), pointer :: required_extension, extension_name
    integer(c_int32_t) :: i, j
    type(c_ptr), pointer :: raw_c_ptr_ptr
    logical(c_bool) :: found

    has_support = .false.

    ! First we create our required device extensions.
    call this%create_required_physical_device_extensions(required_device_extensions)

    ! Now, let us store the vector of available device extensions.
    if (vk_enumerate_device_extension_properties(physical_device, c_null_ptr, extension_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate device extension properties."
    end if

    allocate(extension_properties)
    available_extensions = new_vec(sizeof(extension_properties), 0_8)
    call available_extensions%resize(int(extension_count, c_int64_t), extension_properties)
    deallocate(extension_properties)

    ! This is pointing the function straight into the internal C array of the vector.
    if (vk_enumerate_device_extension_properties(physical_device, c_null_ptr, extension_count, available_extensions%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to enumerate device extension properties."
    end if


    ! Check we have all required device extensions.
    do i = 1,int(required_device_extensions%size())

      ! Shoot that char * straight into a fortran string.
      call c_f_pointer(required_device_extensions%get(int(i, c_int64_t)), raw_c_ptr_ptr)
      required_extension => string_from_c(raw_c_ptr_ptr)

      found = .false.

      ! Now we need to see if we have this one in there.
      extension_search: do j = 1,int(available_extensions%size())
        call c_f_pointer(available_extensions%get(int(j, c_int64_t)), extension_properties)

        ! Let us convert the extension name from a char array into a string.
        extension_name => character_array_to_string_pointer(extension_properties%extension_name)

        if (required_extension == extension_name) then
          found = .true.
          deallocate(extension_name)
          print"(A)","[Vulkan]: Found required physical device extension ["//required_extension//"]"
          exit extension_search
        end if

        deallocate(extension_name)
      end do extension_search

      ! Found will continue to be false or true when we're done with this loop.
      ! If we're missing something, continue to let it be false so we can return if it has support.
      ! If we found everything, this will always finish this loop as true.
      if (.not. found) then
        print"(A)","[Vulkan]: Physical device extension ["//required_extension//"] is missing."
        exit
      end if
    end do

    !! fixme: this thing needs a GC.
    call required_device_extensions%destroy()

    call available_extensions%destroy()

    has_support = found

    ! So now we must query the swapchain support.
    ! If it has no swapchain support, then we can't use this device.
    ! But we're only going to run this if the device passed all the other checks.
    if (has_support) then
      has_support = this%query_swapchain_support(physical_device, swapchain_support_details)

      call swapchain_support_details%formats%destroy()
      call swapchain_support_details%present_modes%destroy()

      if (.not. has_support) then
        print"(A)", "[Vulkan]: Physical device is missing swapchain support. Skipping."
      end if
    end if
  end function vk_driver_check_device_extension_support

  ! We use this to check the physical device has everything.
  ! Then we enable it in the logical device.
  ! This allows for it to be passed around by using this one function
  subroutine vk_driver_create_required_physical_device_extensions(this, required_device_extensions)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! character **
    type(vec), intent(inout) :: required_device_extensions
    character(len = :, kind = c_char), pointer :: required_extension

    required_device_extensions = new_vec(sizeof(c_null_ptr), 0_8, device_extensions_vec_gc)

    allocate(character(len = len(VK_KHR_SWAPCHAIN_EXTENSION_NAME), kind = c_char) :: required_extension)
    required_extension = VK_KHR_SWAPCHAIN_EXTENSION_NAME

    call required_device_extensions%push_back(c_loc(required_extension))

    call required_device_extensions%shrink_to_fit()
  end subroutine vk_driver_create_required_physical_device_extensions


  subroutine device_extensions_vec_gc(raw_c_ptr_ptr)
    implicit none

    type(c_ptr), intent(in), value :: raw_c_ptr_ptr
    type(c_ptr), pointer :: raw_c_ptr
    character(len = :, kind = c_char), pointer :: str

    call c_f_pointer(raw_c_ptr_ptr, raw_c_ptr)
    str => string_from_c(raw_c_ptr)

    deallocate(str)
  end subroutine device_extensions_vec_gc


  function vk_driver_find_queue_families(this, physical_device) result(queue_family_indices)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_physical_device), intent(in), value :: physical_device
    type(forvulkan_queue_family_indices) :: queue_family_indices
    integer(c_int32_t) :: queue_family_count, i, present_support
    ! VkQueueFamilyProperties
    type(vec) :: queue_families
    type(vk_queue_family_properties), pointer :: properties

    ! Sniff out those graphics queue families.

    print"(A)","[Vulkan]: Finding queue families."

    call vk_get_physical_device_queue_family_properties(physical_device, queue_family_count, c_null_ptr)

    allocate(properties)
    queue_families = new_vec(sizeof(properties), int(queue_family_count, c_int64_t))
    call queue_families%resize(int(queue_family_count, c_int64_t), properties)
    deallocate(properties)

    call vk_get_physical_device_queue_family_properties(physical_device, queue_family_count, queue_families%get(1_8))

    do i = 1, queue_family_count
      ! We're just straight shooting this right from C into Fortran.
      call c_f_pointer(queue_families%get(int(i, c_int64_t)), properties)

      ! Check if we can do graphics on this queue.
      if (.not. queue_family_indices%graphics_family_has_value .and. iand(properties%queue_flags, VK_QUEUE_GRAPHICS_BIT) == VK_TRUE) then
        ! Move it into C indexing.
        queue_family_indices%graphics_family = i - 1
        queue_family_indices%graphics_family_has_value = .true.
      end if

      ! Check if we can actually present on this queue.
      if (vk_get_physical_device_surface_support_khr(physical_device, i - 1, this%window_surface, present_support) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to get physical device surface support."
      end if

      if (.not. queue_family_indices%present_family_has_value .and. present_support == VK_TRUE) then
        ! Move it into C indexing.
        queue_family_indices%present_family = i - 1
        queue_family_indices%present_family_has_value = .true.
      end if

      ! Now if we have graphics, and we have present support, we found it.
      if (queue_family_indices%graphics_family_has_value .and. queue_family_indices%present_family_has_value) then
        exit
      end if
    end do

    call queue_families%destroy()
  end function vk_driver_find_queue_families


  subroutine vk_driver_create_logical_device(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! const char **
    type(vec) :: required_validation_layers
    type(vk_device_queue_create_info) :: logical_device_queue_create_info
    real(c_float), target :: queue_priority
    type(vk_physical_device_features), target :: physical_device_features
    type(vec) :: logical_device_queue_create_infos
    type(vk_device_create_info), target :: logical_device_create_info
    type(forvulkan_queue_family_indices) :: physical_queue_family_indices
    type(int32_set) :: physical_device_unique_queue_families
    integer(c_int32_t) :: i
    type(vec) :: required_physical_device_extensions

    print"(A)","[Vulkan]: Creating logical device."

    ! Physical and logical devices can have multiple queues.
    physical_queue_family_indices = this%find_queue_families(this%physical_device)

    logical_device_queue_create_infos = new_vec(sizeof(logical_device_queue_create_info), 0_8)

    ! We condense them down if they overlap.
    physical_device_unique_queue_families = new_int32_set()
    call physical_device_unique_queue_families%push_array([physical_queue_family_indices%graphics_family, physical_queue_family_indices%present_family])

    ! Now iterate to create the queue info.
    queue_priority = 1.0

    do i = 1,physical_device_unique_queue_families%size
      logical_device_queue_create_info%s_type = VK_STRUCTURE_TYPE%DEVICE%QUEUE_CREATE_INFO
      logical_device_queue_create_info%queue_family_index = physical_device_unique_queue_families%data(i)
      logical_device_queue_create_info%queue_count = 1
      logical_device_queue_create_info%p_queue_priorities = c_loc(queue_priority)

      call logical_device_queue_create_infos%push_back(logical_device_queue_create_info)
    end do

    call physical_device_unique_queue_families%destroy()

    !? Device features is left alone for now. I'm just putting this here to copy the C code.
    physical_device_features = vk_physical_device_features()

    ! Create the create info for the logical device.

    call this%create_required_physical_device_extensions(required_physical_device_extensions)

    logical_device_create_info%s_type = VK_STRUCTURE_TYPE%DEVICE%CREATE_INFO
    logical_device_create_info%queue_create_info_count = int(logical_device_queue_create_infos%size())
    logical_device_create_info%p_queue_create_infos = logical_device_queue_create_infos%get(1_8)
    logical_device_create_info%p_enabled_features = c_loc(physical_device_features)
    logical_device_create_info%enabled_extension_count = int(required_physical_device_extensions%size())
    logical_device_create_info%pp_enabled_extension_names = required_physical_device_extensions%get(1_8)

    if (this%DEBUG_MODE) then
      call this%create_required_validation_layers(required_validation_layers)
      logical_device_create_info%enabled_layer_count = int(required_validation_layers%size())
      ! Passing in the underlying C array.
      logical_device_create_info%pp_enabled_layer_names = required_validation_layers%get(1_8)
    else
      logical_device_create_info%enabled_layer_count = 0
    end if

    if (vk_create_device(this%physical_device, c_loc(logical_device_create_info), c_null_ptr, this%logical_device) /= VK_SUCCESS) then
      error stop "[Vulkan]: Failed to create logical device."
    end if

    ! Now we can create the graphics queues so the logical devices can control the physical device queues.
    call vk_get_device_queue(this%logical_device, physical_queue_family_indices%graphics_family, 0, this%graphics_queue)
    call vk_get_device_queue(this%logical_device, physical_queue_family_indices%present_family, 0, this%present_queue)

    call logical_device_queue_create_infos%destroy()
    call required_validation_layers%destroy()
    call required_physical_device_extensions%destroy()
  end subroutine vk_driver_create_logical_device


  function vk_driver_query_swapchain_support(this, physical_device, swapchain_support_details) result(has_swapchain_support)
    implicit none

    class(vk_driver), intent(inout), target :: this
    type(vk_physical_device), intent(in), value :: physical_device
    logical(c_bool) :: has_swapchain_support
    type(forvulkan_swapchain_support_details), intent(inout), target :: swapchain_support_details
    integer(c_int32_t) :: format_count, present_mode_count
    type(vk_surface_format_khr), pointer :: surface_format_pointer

    has_swapchain_support = .true.

    print"(A)","[Vulkan]: Querying swapchain support information."

    ! First, get device surface capabilities.
    if (vk_get_physical_device_surface_capabilities_khr(physical_device, this%window_surface, c_loc(swapchain_support_details%capabilities)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get physical device surface capabilities."
    end if

    ! Next, we must get the available device window surface formats.
    if (vk_get_physical_device_surface_formats_khr(physical_device, this%window_surface, format_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get available physical device surface formats."
    end if

    ! If it has none, well, we tried.
    if (format_count == 0) then
      print"(A)","[Vulkan]: Device has no surface formats."
      has_swapchain_support = .false.
      return
    end if

    print"(A)","[Vulkan]: Found ["//int_to_string(format_count)//"] supported physical device surface formats."

    ! And if it does, we can get all of them.
    allocate(surface_format_pointer)
    swapchain_support_details%formats = new_vec(sizeof(surface_format_pointer), 0_8)
    call swapchain_support_details%formats%resize(int(format_count, c_int64_t), surface_format_pointer)
    deallocate(surface_format_pointer)

    ! We're passing in the underlying C array pointer.
    if (vk_get_physical_device_surface_formats_khr(physical_device, this%window_surface, format_count, swapchain_support_details%formats%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get available physical device surface formats."
    end if

    ! Now, we must get the present modes
    if (vk_get_physical_device_surface_present_modes_khr(physical_device, this%window_surface, present_mode_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get avilable physical device surface present modes."
    end if

    ! If it has no surface present modes, welp, I guess that's that.
    if (present_mode_count == 0) then
      print"(A)","[Vulkan]: Device has no surface present modes."
      has_swapchain_support = .false.
      return
    end if

    print"(A)","[Vulkan]: Found ["//int_to_string(present_mode_count)//"] supported physical device present modes."

    ! Again, if it does, we can get all of them.
    swapchain_support_details%present_modes = new_vec(sizeof(0_4), 0_8)
    call swapchain_support_details%present_modes%resize(int(present_mode_count, c_int64_t), 0_4)

    if (vk_get_physical_device_surface_present_modes_khr(physical_device, this%window_surface, present_mode_count, swapchain_support_details%present_modes%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get avilable physical device surface present modes."
    end if
  end function vk_driver_query_swapchain_support







  subroutine vk_driver_create_swapchain(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(forvulkan_swapchain_support_details), target :: swapchain_support_details
    type(vk_surface_format_khr) :: selected_surface_format
    ! VkPresentModeKHR
    integer(c_int32_t) :: selected_present_mode
    type(vk_extent_2d) :: selected_extent
    integer(c_int32_t) :: selected_image_count
    type(vk_swapchain_create_info_khr), target :: create_info
    type(forvulkan_queue_family_indices) :: queue_family_indices
    integer(c_int32_t), dimension(2), target :: queue_indices_array
    integer(c_int32_t) :: swappchain_image_count

    print"(A)","[Vulkan]: Creating swapchain."

    if (.not. this%query_swapchain_support(this%physical_device, swapchain_support_details)) then
      error stop "[Vulkan] Severe Error: This physical device was already tested to have swapchain support, suddenly it does not."
    end if

    selected_surface_format = select_swap_surface_format(swapchain_support_details%formats)
    selected_present_mode = select_swap_present_mode(swapchain_support_details%present_modes)
    selected_extent = select_swap_extent(swapchain_support_details%capabilities)
    selected_image_count = select_image_count(swapchain_support_details%capabilities)

    create_info%s_type = VK_STRUCTURE_TYPE%SWAPCHAIN_CREATE_INFO_KHR
    create_info%surface = this%window_surface
    create_info%min_image_count = selected_image_count
    create_info%image_format = selected_surface_format%format
    create_info%image_color_space = selected_surface_format%color_space
    create_info%image_extent = selected_extent
    create_info%image_array_layers = 1
    create_info%image_usage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT

    queue_family_indices = this%find_queue_families(this%physical_device)

    if (queue_family_indices%graphics_family /= queue_family_indices%present_family) then
      queue_indices_array = [queue_family_indices%graphics_family, queue_family_indices%present_family]
      create_info%image_sharing_mode = VK_SHARING_MODE_CONCURRENT
      create_info%queue_family_index_count = 2
      create_info%p_queue_family_indices = c_loc(queue_indices_array)
    else
      create_info%image_sharing_mode = VK_SHARING_MODE_EXCLUSIVE
      create_info%queue_family_index_count = 0
      create_info%p_queue_family_indices = c_null_ptr
    end if

    create_info%pre_transform = swapchain_support_details%capabilities%current_transform
    create_info%composite_alpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR
    create_info%present_mode = selected_present_mode
    create_info%old_swapchain%data = VK_NULL_HANDLE

    if (vk_create_swapchain_khr(this%logical_device, c_loc(create_info), c_null_ptr, this%swapchain) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create the swapchain."
    end if

    ! Now, we shall create the swapchain images.
    if (vk_get_swapchain_images_khr(this%logical_device, this%swapchain, swappchain_image_count, c_null_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get swapchain images."
    end if

    this%swapchain_images = new_vec(sizeof(0_8), 0_8)
    call this%swapchain_images%resize(int(swappchain_image_count, c_int64_t), 0_8)

    if (vk_get_swapchain_images_khr(this%logical_device, this%swapchain, swappchain_image_count, this%swapchain_images%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to get swapchain images."
    end if

    ! Finally, set the module variables so we can reuse them.
    this%swapchain_image_format%data = selected_surface_format%format
    this%swapchain_extent = selected_extent

    call swapchain_support_details%formats%destroy()
    call swapchain_support_details%present_modes%destroy()
  end subroutine vk_driver_create_swapchain


  function select_swap_surface_format(available_formats) result(selected_surface_format)
    implicit none

    type(vec), intent(inout) :: available_formats
    integer(c_int64_t) :: i
    type(vk_surface_format_khr), pointer :: available_format_pointer
    type(vk_surface_format_khr) :: selected_surface_format

    print"(A)","[Vulkan]: Searching for [BGRA8] surface format availability."

    search: do i = 1,available_formats%size()
      call c_f_pointer(available_formats%get(i), available_format_pointer)

      ! We will prefer this format, BGRA8. But,
      ! TODO: look into RGBA8.
      if (available_format_pointer%format == VK_FORMAT_B8G8R8A8_SRGB .and. available_format_pointer%color_space == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR) then
        selected_surface_format%color_space = available_format_pointer%color_space
        selected_surface_format%format = available_format_pointer%format
        print"(A)","[Vulkan]: [BGRA8] surface format is selected."
        return
      end if
    end do search


    ! So, if we didn't find anything:
    ! We will just select the first thing we have available.
    print"(A)","[Vulkan]: Surface format [BGRA8] unavailable. Defaulting selection."

    call c_f_pointer(available_formats%get(1_8), available_format_pointer)
    selected_surface_format%color_space = available_format_pointer%color_space
    selected_surface_format%format = available_format_pointer%format
  end function select_swap_surface_format


  function select_swap_present_mode(available_present_modes) result(selected_present_mode)
    implicit none

    ! VkPresentModeKHR
    type(vec) :: available_present_modes
    ! VkPresentModeKHR
    integer(c_int32_t) :: selected_present_mode
    integer(c_int32_t), pointer :: available_present_mode_pointer
    integer(c_int64_t) :: i

    print"(A)","[Vulkan]: Searching for [mailbox] present mode."

    ! We're going to try to find mailbox support.
    do i = 1,available_present_modes%size()
      call c_f_pointer(available_present_modes%get(i), available_present_mode_pointer)
      if (available_present_mode_pointer == VK_PRESENT_MODE_MAILBOX_KHR) then
        selected_present_mode = available_present_mode_pointer
        print"(A)","[Vulkan]: [mailbox] present mode is selected."
        return
      end if
    end do

    ! If we didn't find mailbox support, just use FIFO.

    print"(A)","[Vulkan]: [mailbox] present mode not available. Defaulting to [fifo]"

    selected_present_mode = VK_PRESENT_MODE_FIFO_KHR
  end function select_swap_present_mode


  function select_swap_extent(capabilities) result(selected_extent)
    use :: math_helpers
    implicit none

    type(vk_surface_capabilities_khr), intent(in) :: capabilities
    type(vk_extent_2d) :: selected_extent

    ! If this is wayland, or macos this will get triggered.
    ! uint32 max goes into negatives using direct casting to int32.
    ! In fact, it just equals -1. :)
    if (capabilities%current_extent%width == -1) then
      ! The vulkan tutorial was using a whole bunch of variables but I'm just going to inline it and reuse.
      call glfw_get_framebuffer_size(selected_extent%width, selected_extent%height)

      selected_extent%width = clamp_i32(selected_extent%width, capabilities%min_image_extent%width, capabilities%max_image_extent%width)
      selected_extent%height = clamp_i32(selected_extent%height, capabilities%min_image_extent%height, capabilities%max_image_extent%height)
    else
      ! If we didn't trigger that, we can just use it directly.
      selected_extent%width = capabilities%current_extent%width
      selected_extent%height = capabilities%current_extent%height
    end if
  end function select_swap_extent


  function select_image_count(capabilities) result(selected_image_count)
    implicit none

    type(vk_surface_capabilities_khr), intent(in) :: capabilities
    integer(c_int32_t) :: selected_image_count

    selected_image_count = capabilities%min_image_count + 1

    if (capabilities%max_image_count > 0 .and. selected_image_count > capabilities%max_image_count) then
      selected_image_count = capabilities%max_image_count
    end if
  end function select_image_count


  subroutine vk_driver_create_image_views(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int64_t) :: i
    type(vk_image), pointer :: image_pointer
    type(vk_image_view), pointer :: image_view_pointer
    type(vk_image_view_create_info), target :: image_view_create_info

    print*,  this%swapchain_images%size()

    this%swapchain_image_views = new_vec(sizeof(0_8), 0_8)
    call this%swapchain_image_views%resize(this%swapchain_images%size(), 0_8)

    do i = 1,this%swapchain_images%size()
      image_view_create_info%s_type = VK_STRUCTURE_TYPE%IMAGE%VIEW_CREATE_INFO

      call c_f_pointer(this%swapchain_images%get(i), image_pointer)
      image_view_create_info%image = image_pointer

      image_view_create_info%view_type = VK_IMAGE_VIEW_TYPE_2D
      image_view_create_info%format = this%swapchain_image_format

      image_view_create_info%components%r = VK_COMPONENT_SWIZZLE_IDENTITY
      image_view_create_info%components%g = VK_COMPONENT_SWIZZLE_IDENTITY
      image_view_create_info%components%b = VK_COMPONENT_SWIZZLE_IDENTITY
      image_view_create_info%components%a = VK_COMPONENT_SWIZZLE_IDENTITY

      image_view_create_info%subresource_range%aspect_mask = VK_IMAGE_ASPECT_COLOR_BIT
      image_view_create_info%subresource_range%base_mip_level = 0
      image_view_create_info%subresource_range%level_count = 1
      image_view_create_info%subresource_range%base_array_layer = 0
      image_view_create_info%subresource_range%layer_count = 1

      call c_f_pointer(this%swapchain_image_views%get(i), image_view_pointer)

      if (vk_create_image_view(this%logical_device, c_loc(image_view_create_info), c_null_ptr, image_view_pointer) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to create image view. Index ["//int64_to_string(i)//"]"
      end if
    end do
  end subroutine vk_driver_create_image_views


  subroutine vk_driver_create_render_pass(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_attachment_description), target :: color_attachment_description
    type(vk_attachment_reference), target :: color_attachment_reference
    type(vk_subpass_description_t), target :: subpass
    type(vk_render_pass_create_info), target  :: render_pass_create_info
    type(vk_subpass_dependency), target :: dependency

    color_attachment_description%format = this%swapchain_image_format
    color_attachment_description%samples = VK_SAMPLE_COUNT_1_BIT
    color_attachment_description%load_op = VK_ATTACHMENT_LOAD_OP_CLEAR
    color_attachment_description%store_op = VK_ATTACHMENT_STORE_OP_STORE
    color_attachment_description%stencil_load_op = VK_ATTACHMENT_LOAD_OP_DONT_CARE
    color_attachment_description%stencil_store_op = VK_ATTACHMENT_STORE_OP_DONT_CARE
    color_attachment_description%initial_layout = VK_IMAGE_LAYOUT_UNDEFINED
    color_attachment_description%final_layout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR

    color_attachment_reference%attachment = 0
    color_attachment_reference%layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL

    subpass%pipeline_bind_point = VK_PIPELINE_BIND_POINT_GRAPHICS
    subpass%color_attachment_count = 1
    subpass%p_color_attachments = c_loc(color_attachment_reference)

    dependency%src_subpass = VK_SUBPASS_EXTERNAL
    dependency%dst_subpass = 0
    dependency%src_stage_mask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    dependency%src_access_mask = 0
    dependency%dst_stage_mask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT
    dependency%dst_access_mask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT

    render_pass_create_info%s_type = VK_STRUCTURE_TYPE%RENDER_PASS_CREATE_INFO
    render_pass_create_info%attachment_count = 1
    render_pass_create_info%p_attachments = c_loc(color_attachment_description)
    render_pass_create_info%subpass_count = 1
    render_pass_create_info%p_subpasses = c_loc(subpass)
    render_pass_create_info%dependency_count = 1
    render_pass_create_info%p_dependencies = c_loc(dependency)

    if (vk_create_render_pass(this%logical_device, c_loc(render_pass_create_info), c_null_ptr, this%render_pass) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create render pass."
    end if
  end subroutine vk_driver_create_render_pass


  subroutine vk_driver_create_descriptor_set_layout(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_descriptor_set_layout_binding), target :: ubo_layout_binding
    type(vk_descriptor_set_layout_create_info), target :: layout_info

    ubo_layout_binding%binding = 0
    ubo_layout_binding%descriptor_type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
    ubo_layout_binding%descriptor_count = 1
    ubo_layout_binding%stage_flags = VK_SHADER_STAGE_VERTEX_BIT
    ubo_layout_binding%p_immutable_samplers = c_null_ptr

    layout_info%s_type = VK_STRUCTURE_TYPE%DESCRIPTOR_SET_LAYOUT_CREATE_INFO
    layout_info%binding_count = 1
    layout_info%p_bindings = c_loc(ubo_layout_binding)

    if (vk_create_descriptor_set_layout(this%logical_device, c_loc(layout_info), c_null_ptr, this%descriptor_set_layout) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create descriptor set layout."
    end if
  end subroutine vk_driver_create_descriptor_set_layout


end module vulkan_driver
