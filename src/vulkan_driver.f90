module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: string_f90
  use :: vector
  use :: forvulkan
  use :: vector_3f
  use :: vector_2f
  use :: integer32_set
  use :: vulkan_vertex
  use :: vulkan_uniform_buffer
  use :: math_helpers
  use :: stb_image

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
    type(vk_image) :: texture_image
    type(vk_device_memory) :: texture_image_memory
    type(vk_image_view) :: texture_image_view
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
    !! fixme: end temporary!
    procedure :: create_glfw => vk_driver_create_glfw
    procedure :: destroy => vk_driver_destroy
    procedure :: ensure_extensions_present => vk_driver_ensure_extensions_present
    procedure :: create_required_extensions => vk_driver_create_required_extensions
    procedure :: create_vulkan_instance => vk_driver_create_vulkan_instance
    procedure :: create_vulkan_instance_create_info => vk_driver_create_vulkan_instance_create_info
    procedure :: create_required_validation_layers => vk_driver_create_required_validation_layers
    procedure :: create_debug_messenger_struct => vk_driver_create_debug_messenger_struct
    procedure, nopass :: create_app_info => vk_driver_create_app_info
    procedure :: clean_up_swapchain => vk_driver_clean_up_swapchain
    procedure :: ensure_validation_layer_support => vk_driver_ensure_validation_layer_support
    procedure :: setup_debug_messenger => vk_driver_setup_debug_messenger
    procedure :: create_surface => vk_driver_create_surface
    procedure :: select_physical_device => vk_driver_select_physical_device
    procedure :: device_is_suitable => vk_driver_device_is_suitable
    procedure :: check_device_extension_support => vk_driver_check_device_extension_support
    procedure, nopass :: create_required_physical_device_extensions => vk_driver_create_required_physical_device_extensions
    procedure :: find_queue_families => vk_driver_find_queue_families
    procedure :: create_logical_device => vk_driver_create_logical_device
    procedure :: query_swapchain_support => vk_driver_query_swapchain_support
    procedure :: create_swapchain => vk_driver_create_swapchain
    procedure :: create_image_views => vk_driver_create_image_views
    procedure :: create_render_pass => vk_driver_create_render_pass
    procedure :: create_descriptor_set_layout => vk_driver_create_descriptor_set_layout
    procedure :: create_graphics_pipeline => vk_driver_create_graphics_pipeline
    procedure :: create_framebuffers => vk_driver_create_framebuffers
    procedure :: create_command_pool => vk_driver_create_command_pool
    procedure :: create_vertex_buffer => vk_driver_create_vertex_buffer
    procedure :: create_buffer => vk_driver_create_buffer
    procedure :: find_memory_type => vk_driver_find_memory_type
    procedure :: copy_buffer => vk_driver_copy_buffer
    procedure :: create_index_buffer => vk_driver_create_index_buffer
    procedure :: create_uniform_buffers => vk_driver_create_uniform_buffers
    procedure :: create_descriptor_pool => vk_driver_create_descriptor_pool
    procedure :: create_descriptor_sets => vk_driver_create_descriptor_sets
    procedure :: create_command_buffers => vk_driver_create_command_buffers
    procedure :: create_sync_objects => vk_driver_create_sync_objects
    procedure :: draw_frame => vk_driver_draw_frame
    procedure :: record_command_buffer => vk_driver_record_command_buffer
    procedure :: update_uniform_buffer => vk_driver_update_uniform_buffer
    procedure :: recreate_swapchain => vk_driver_recreate_swapchain
    procedure :: create_texture_image => vk_driver_create_texture_image
    procedure :: create_image => vk_driver_create_image
    procedure :: begin_single_time_commands => vk_driver_begin_single_time_commands
    procedure :: end_single_time_commands => vk_driver_end_single_time_commands
    procedure :: transition_image_layout => vk_driver_transition_image_layout
    procedure :: copy_buffer_to_image => vk_driver_copy_buffer_to_image
    procedure :: create_texture_image_view => vk_driver_create_texture_image_view
    procedure :: create_image_view => vk_driver_create_image_view
  end type vk_driver


  !! TODO: This stuff should probably be part of the type

  ! This is a trick to pass the mutable boolean to the framebuffer resize callback.
  type(c_ptr) :: resized_loc
! I don't feel like bringing in vector so this will just run as fast as it will.
  real(c_float) :: time = 0.0

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
    type(vertex), dimension(4) :: vertices
    integer(c_int32_t), dimension(6) :: indices

    vertices(1) = vertex(vec2f(-0.5, -0.5), vec3f(1.0, 0.0, 0.0))
    vertices(2) = vertex(vec2f(0.5,  -0.5), vec3f(0.0, 1.0, 0.0))
    vertices(3) = vertex(vec2f(0.5,   0.5), vec3f(0.0, 0.0, 1.0))
    vertices(4) = vertex(vec2f(-0.5,  0.5), vec3f(1.0, 1.0, 1.0))

    indices = [0,1,2,2,3,0]

    this%indices_size = size(indices)

    call this%create_glfw(800, 600)

    call this%ensure_extensions_present()

    call this%ensure_validation_layer_support()

    call this%create_vulkan_instance()

    call this%setup_debug_messenger()

    call this%create_surface()

    call this%select_physical_device()

    call this%create_logical_device()

    call this%create_swapchain()

    call this%create_image_views()

    call this%create_render_pass()

    call this%create_descriptor_set_layout()

    call this%create_graphics_pipeline()

    call this%create_framebuffers()

    call this%create_command_pool()

    call this%create_texture_image()

    call this%create_texture_image_view()

    call this%create_vertex_buffer(vertices)

    call this%create_index_buffer(indices)

    call this%create_uniform_buffers()

    call this%create_descriptor_pool()

    call this%create_descriptor_sets()

    call this%create_command_buffers()

    call this%create_sync_objects()
  end subroutine vk_driver_init



!* MAIN LOOP. ====================================================================


  subroutine vk_driver_main_loop(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! integer(c_int32_t) :: a

    ! a = 0

    do while(.not. glfw_window_should_close())
      call glfw_poll_events()
      call this%draw_frame()

      !   if (a >= 100) then
      !     ! call glfw_close_window()
      !   end if

      !   a = a + 1

      if (glfw_get_key(GLFW_KEY_ESCAPE) == GLFW_PRESS) then
        call glfw_close_window()
      end if
    end do

    if (vk_device_wait_idle(this%logical_device) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait idle on logical device."
    end if
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

    call vk_destroy_image(this%logical_device, this%texture_image, c_null_ptr)

    call vk_free_memory(this%logical_device, this%texture_image_memory, c_null_ptr)

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

    call this%create_vulkan_instance_create_info(vulkan_create_info, app_info, before_init_messenger_create_info, required_extensions, required_validation_layers)

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


  subroutine vk_driver_create_vulkan_instance_create_info(this, vulkan_create_info, app_info, before_init_messenger_create_info, required_extensions, required_validation_layers)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_instance_create_info), intent(inout) :: vulkan_create_info
    type(vk_application_info), intent(in), target :: app_info
    type(vk_debug_utils_messenger_create_info_ext), intent(inout), target :: before_init_messenger_create_info
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

    if (this%DEBUG_MODE) then
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


  subroutine vk_driver_create_app_info(app_info, app_name, engine_name)
    implicit none

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


  subroutine vk_driver_setup_debug_messenger(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_debug_utils_messenger_create_info_ext), target :: debug_messenger_create_info

    ! Don't need this if we're not in debug mode.
    if (.not. this%DEBUG_MODE) then
      return
    end if

    print"(A)","[Vulkan]: Setting up debug messenger."

    call this%create_debug_messenger_struct(debug_messenger_create_info)

    if (forvulkan_create_debug_utils_messenger_ext(this%vulkan_instance, c_loc(debug_messenger_create_info), c_null_ptr, this%debug_messenger) /= VK_SUCCESS) then
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
  subroutine vk_driver_create_required_physical_device_extensions(required_device_extensions)
    implicit none

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



  subroutine vk_driver_create_graphics_pipeline(this)
    use :: vulkan_shader_compiler
    implicit none

    ! TODO: Break this monstrosity up.

    class(vk_driver), intent(inout), target :: this
    type(vk_pipeline_shader_stage_create_info) :: vertex_shader_stage_info, fragment_shader_stage_info
    character(len = 5, kind = c_char), target :: vert_p_name, frag_p_name
    type(vk_pipeline_shader_stage_create_info), dimension(2), target :: shader_stages
    ! VkDynamicState
    integer(c_int32_t), dimension(2), target :: dynamic_states
    type(vk_pipeline_dynamic_state_create_info), target :: dynamic_state_create_info
    type(vk_pipeline_vertex_input_state_create_info), target :: vertex_input_create_info
    type(vk_pipeline_input_assembly_state_create_info), target :: input_assembly_create_info
    type(vk_viewport) :: viewport
    type(vk_rect_2d) :: scissor
    type(vk_pipeline_viewport_state_create_info), target :: viewport_state_create_info
    type(vk_pipeline_rasterization_state_create_info), target :: rasterization_state_create_info
    type(vk_pipeline_multisample_state_create_info), target :: multisampling_create_info
    type(vk_pipeline_color_blend_attachment_state), target :: color_blend_attachment
    type(vk_pipeline_color_blend_state_create_info), target :: color_blending_create_info
    type(vk_pipeline_layout_create_info), target :: pipeline_layout_create_info
    type(vk_graphics_pipeline_create_info), target :: graphics_pipeline_create_info
    type(vk_vertex_input_binding_description), target :: binding_description
    type(vk_vertex_input_attribute_description), dimension(2), target :: attribute_descriptions

    ! First compile GLSL into shader modules.
    this%vertex_shader_module = compile_glsl_shaders(this%logical_device, "vertex.vert")
    this%fragment_shader_module = compile_glsl_shaders(this%logical_device, "fragment.frag")

    ! Next, Create the vertex shader stage info.
    vertex_shader_stage_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%SHADER_STAGE_CREATE_INFO
    vertex_shader_stage_info%stage = VK_SHADER_STAGE_VERTEX_BIT
    vertex_shader_stage_info%module = this%vertex_shader_module
    vert_p_name = "main"//achar(0)
    vertex_shader_stage_info%p_name = c_loc(vert_p_name)

    ! Then, create the fragment shader stage create info.
    fragment_shader_stage_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%SHADER_STAGE_CREATE_INFO
    fragment_shader_stage_info%stage = VK_SHADER_STAGE_FRAGMENT_BIT
    fragment_shader_stage_info%module = this%fragment_shader_module
    frag_p_name = "main"//achar(0)
    fragment_shader_stage_info%p_name = c_loc(frag_p_name)

    ! Put them into an array.
    shader_stages = [vertex_shader_stage_info, fragment_shader_stage_info]

    ! Create vertex input create info.

    binding_description = vertex_get_binding_description()
    attribute_descriptions = vertex_get_attribute_descriptions()

    vertex_input_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%VERTEX_INPUT_STATE_CREATE_INFO
    vertex_input_create_info%vertex_binding_description_count = 1
    vertex_input_create_info%vertex_attribute_description_count = size(attribute_descriptions)
    vertex_input_create_info%p_vertex_binding_descriptions = c_loc(binding_description)
    vertex_input_create_info%p_vertex_attribute_descriptions = c_loc(attribute_descriptions)

    ! Set up dynamic states for the pipeline.
    dynamic_states = [VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_SCISSOR]

    dynamic_state_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%DYNAMIC_STATE_CREATE_INFO
    dynamic_state_create_info%dynamic_state_count = size(dynamic_states)
    dynamic_state_create_info%p_dynamic_states = c_loc(dynamic_states)

    ! Set up the input assembly create info.
    input_assembly_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%INPUT_ASSEMBLY_STATE_CREATE_INFO
    input_assembly_create_info%topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST
    input_assembly_create_info%primitive_restart_enabled = VK_FALSE

    ! Set up the viewport.
    viewport%x = 0.0
    viewport%y = 0.0
    viewport%width = this%swapchain_extent%width
    viewport%height = this%swapchain_extent%height
    viewport%min_depth = 0.0
    viewport%max_depth = 1.0

    ! Set up scissor.
    scissor%offset = vk_offset_2d()
    scissor%extent = this%swapchain_extent

    ! Set up viewport state create info.
    viewport_state_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%VIEWPORT_STATE_CREATE_INFO
    viewport_state_create_info%viewport_count = 1
    viewport_state_create_info%scissor_count = 1

    ! Set up rasterization state create info.
    rasterization_state_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%RASTERIZATION_STATE_CREATE_INFO
    rasterization_state_create_info%depth_clamp_enable = VK_FALSE
    rasterization_state_create_info%rasterizer_discard_enable = VK_FALSE
    rasterization_state_create_info%polygon_mode = VK_POLYGON_MODE_FILL
    rasterization_state_create_info%line_width = 1.0
    rasterization_state_create_info%cull_mode = VK_CULL_MODE_NONE! VK_CULL_MODE_BACK_BIT
    rasterization_state_create_info%front_face = VK_FRONT_FACE_COUNTER_CLOCKWISE
    rasterization_state_create_info%depth_bias_enable = VK_FALSE
    rasterization_state_create_info%depth_bias_constant_factor = 0.0
    rasterization_state_create_info%depth_bias_clamp = 0.0
    rasterization_state_create_info%depth_bias_slope_factor = 0.0

    ! We will have multisampling disabled for now.
    multisampling_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%MULTISAMPLE_STATE_CREATE_INFO
    multisampling_create_info%sample_shading_enable = VK_FALSE
    multisampling_create_info%rasterization_samples = VK_SAMPLE_COUNT_1_BIT
    multisampling_create_info%min_sample_shading = 1.0
    multisampling_create_info%p_sample_mask = c_null_ptr
    multisampling_create_info%alpha_to_coverage_enable = VK_FALSE
    multisampling_create_info%alpha_to_one_enable = VK_FALSE

    ! Set up color blend attachment.
    color_blend_attachment%color_write_mask = ior(VK_COLOR_COMPONENT_R_BIT, ior(VK_COLOR_COMPONENT_G_BIT, ior(VK_COLOR_COMPONENT_B_BIT, VK_COLOR_COMPONENT_A_BIT)))
    color_blend_attachment%blend_enable = VK_FALSE
    color_blend_attachment%src_color_blend_factor = VK_BLEND_FACTOR_ONE
    color_blend_attachment%dst_color_blend_factor = VK_BLEND_FACTOR_ZERO
    color_blend_attachment%color_blend_op = VK_BLEND_OP_ADD
    color_blend_attachment%src_alpha_blend_factor = VK_BLEND_FACTOR_ONE
    color_blend_attachment%dst_alpha_blend_factor = VK_BLEND_FACTOR_ZERO
    color_blend_attachment%alpha_blend_op = VK_BLEND_OP_ADD

    ! Set up color blending create info.
    color_blending_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%COLOR_BLEND_STATE_CREATE_INFO
    color_blending_create_info%logical_op_enable = VK_FALSE
    color_blending_create_info%logic_op = VK_LOGIC_OP_COPY
    color_blending_create_info%attachment_count = 1
    color_blending_create_info%p_attachments = c_loc(color_blend_attachment)
    color_blending_create_info%blend_constants = [0.0, 0.0, 0.0, 0.0]

    ! Set up the pipeline layout create info.
    pipeline_layout_create_info%s_type = VK_STRUCTURE_TYPE%PIPELINE%LAYOUT_CREATE_INFO
    pipeline_layout_create_info%set_layout_count = 1
    pipeline_layout_create_info%p_set_layouts = c_loc(this%descriptor_set_layout)
    pipeline_layout_create_info%push_constant_range_count = 0
    pipeline_layout_create_info%p_push_constant_ranges = c_null_ptr

    ! Now, create the pipeline layout.
    if (vk_create_pipeline_layout(this%logical_device, c_loc(pipeline_layout_create_info), c_null_ptr, this%pipeline_layout) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create pipeline layout."
    end if

    ! Set up the graphics pipeline create info.
    graphics_pipeline_create_info%s_type = VK_STRUCTURE_TYPE%GRAPHICS_PIPELINE_CREATE_INFO
    graphics_pipeline_create_info%stage_count = 2
    graphics_pipeline_create_info%p_stages = c_loc(shader_stages)

    graphics_pipeline_create_info%p_vertex_input_state = c_loc(vertex_input_create_info)
    graphics_pipeline_create_info%p_input_assembly_state = c_loc(input_assembly_create_info)
    graphics_pipeline_create_info%p_viewport_state = c_loc(viewport_state_create_info)
    graphics_pipeline_create_info%p_rasterization_state = c_loc(rasterization_state_create_info)
    ! todo: If not drawing, go back and make this.
    graphics_pipeline_create_info%p_multisample_state = c_loc(multisampling_create_info)
    graphics_pipeline_create_info%p_depth_stencil_state = c_null_ptr
    graphics_pipeline_create_info%p_color_blend_state = c_loc(color_blending_create_info)
    graphics_pipeline_create_info%p_dynamic_state = c_loc(dynamic_state_create_info)

    graphics_pipeline_create_info%layout = this%pipeline_layout
    graphics_pipeline_create_info%render_pass = this%render_pass
    graphics_pipeline_create_info%subpass = 0

    graphics_pipeline_create_info%base_pipeline_handle%data = VK_NULL_HANDLE
    graphics_pipeline_create_info%base_pipeline_index = -1

    if (vk_create_graphics_pipelines(this%logical_device, VK_NULL_HANDLE, 1, c_loc(graphics_pipeline_create_info), c_null_ptr, this%graphics_pipeline) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create graphics pipelines."
    end if

    call vk_destroy_shader_module(this%logical_device, this%fragment_shader_module, c_null_ptr)
    call vk_destroy_shader_module(this%logical_device, this%vertex_shader_module, c_null_ptr)
  end subroutine vk_driver_create_graphics_pipeline


  subroutine vk_driver_create_framebuffers(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int64_t) :: i
    type(vk_image_view), dimension(1), target :: attachments
    type(vk_image_view), pointer :: image_view
    type(vk_framebuffer), pointer :: framebuffer_pointer
    type(vk_framebuffer_create_info), target :: frame_buffer_create_info

    this%swapchain_framebuffers = new_vec(sizeof(0_8), this%swapchain_image_views%size())
    call this%swapchain_framebuffers%resize(this%swapchain_image_views%size(), 0_8)

    do i = 1,this%swapchain_framebuffers%size()

      call c_f_pointer(this%swapchain_image_views%get(i), image_view)

      attachments(1) = image_view

      frame_buffer_create_info%s_type = VK_STRUCTURE_TYPE%FRAMEBUFFER_CREATE_INFO
      frame_buffer_create_info%render_pass = this%render_pass
      frame_buffer_create_info%attachment_count = 1
      frame_buffer_create_info%p_attachments = c_loc(attachments)
      frame_buffer_create_info%width = this%swapchain_extent%width
      frame_buffer_create_info%height = this%swapchain_extent%height
      frame_buffer_create_info%layers = 1

      ! We're pointing this into the array from the driver.
      call c_f_pointer(this%swapchain_framebuffers%get(i), framebuffer_pointer)

      if (vk_create_framebuffer(this%logical_device, c_loc(frame_buffer_create_info), c_null_ptr, framebuffer_pointer) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to create framebuffer."
      end if
    end do
  end subroutine vk_driver_create_framebuffers


  subroutine vk_driver_create_command_pool(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(forvulkan_queue_family_indices) :: queue_family_indices
    type(vk_command_pool_create_info), target :: command_pool_create_info

    queue_family_indices = this%find_queue_families(this%physical_device)

    command_pool_create_info%s_type = VK_STRUCTURE_TYPE%COMMAND_POOL_CREATE_INFO
    command_pool_create_info%flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT
    command_pool_create_info%queue_family_index = queue_family_indices%graphics_family

    if (vk_create_command_pool(this%logical_device, c_loc(command_pool_create_info), c_null_ptr, this%command_pool) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create command pool."
    end if
  end subroutine vk_driver_create_command_pool


  subroutine vk_driver_create_vertex_buffer(this, vertices)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vertex), dimension(:), intent(in) :: vertices
    type(vk_device_size) :: buffer_size
    ! void *
    type(c_ptr) :: data
    type(vk_buffer) :: staging_buffer
    type(vk_device_memory) :: staging_buffer_memory

    buffer_size%data = sizeof(vertices(1)) * size(vertices)

    call this%create_buffer(buffer_size, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, ior(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, VK_MEMORY_PROPERTY_HOST_COHERENT_BIT), staging_buffer, staging_buffer_memory)
    if (vk_map_memory(this%logical_device, staging_buffer_memory, vk_device_size(0_8), buffer_size, 0, data) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to map memory."
    end if
    call totally_not_memcpy_vertices(data, vertices)
    call vk_unmap_memory(this%logical_device, staging_buffer_memory)

    call this%create_buffer(buffer_size, ior(VK_BUFFER_USAGE_TRANSFER_DST_BIT, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT), VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, this%vertex_buffer, this%vertex_buffer_memory)
    call this%copy_buffer(staging_buffer, this%vertex_buffer, buffer_size)

    call vk_destroy_buffer(this%logical_device, staging_buffer, c_null_ptr)
    call vk_free_memory(this%logical_device, staging_buffer_memory, c_null_ptr)
  end subroutine vk_driver_create_vertex_buffer


  subroutine totally_not_memcpy_vertices(data, vertices)
    implicit none

    type(c_ptr), intent(in), value :: data
    type(vertex), dimension(:), intent(in) :: vertices
    type(vertex), dimension(:), pointer :: data_in_buffer

    call c_f_pointer(data, data_in_buffer, [size(vertices)])
    data_in_buffer = vertices
  end subroutine totally_not_memcpy_vertices


  subroutine vk_driver_create_buffer(this, buffer_size, usage, properties, buffer, buffer_memory)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! VkBufferUsageFlags
    integer(c_int32_t), intent(in), value :: usage
    ! VkMemoryPropertyFlags
    integer(c_int32_t), intent(in), value :: properties
    type(vk_buffer), intent(inout) :: buffer
    type(vk_device_memory), intent(inout) :: buffer_memory
    type(vk_buffer_create_info), target :: buffer_info
    type(vk_device_size), intent(in), value :: buffer_size
    type(vk_memory_allocate_info), target :: alloc_info
    type(vk_memory_requirements), target :: mem_requirements

    buffer_info%s_type = VK_STRUCTURE_TYPE%BUFFER_CREATE_INFO
    buffer_info%size = buffer_size
    buffer_info%usage = usage
    buffer_info%sharing_mode = VK_SHARING_MODE_EXCLUSIVE

    if (vk_create_buffer(this%logical_device, c_loc(buffer_info), c_null_ptr, buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create buffer."
    end if

    call vk_get_buffer_memory_requirements(this%logical_device, buffer, c_loc(mem_requirements))

    alloc_info%s_type = VK_STRUCTURE_TYPE%MEMORY%ALLOCATE_INFO
    alloc_info%allocation_size = mem_requirements%size
    alloc_info%memory_type_index = this%find_memory_type(mem_requirements%memory_type_bits, properties)

    if (vk_allocate_memory(this%logical_device, c_loc(alloc_info), c_null_ptr, buffer_memory) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate buffer memory."
    end if

    ! todo: put this thing into a more generic function or module, lol. This is horrible.
    if (vk_bind_buffer_memory(this%logical_device, buffer, buffer_memory, vk_device_size(0_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to bind buffer memory."
    end if
  end subroutine vk_driver_create_buffer


  function vk_driver_find_memory_type(this, type_filter, properties) result(t)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int32_t), intent(in), value :: type_filter
    integer(c_int32_t), intent(in), value :: properties
    integer(c_int32_t) :: t
    integer(c_int32_t) :: i
    type(vk_physical_device_memory_properties), target :: mem_properties

    call vk_get_physical_device_memory_properties(this%physical_device, c_loc(mem_properties))

    do i = 0,mem_properties%memory_type_count - 1
      if (iand(type_filter, shiftl(1, i)) /= 0 .and. iand(mem_properties%memory_types(i + 1)%property_flags, properties) == properties) then
        t = i
        return
      end if
    end do

    error stop "[Vulkan] Error: Failed to find suitable memory type."
  end function vk_driver_find_memory_type


  subroutine vk_driver_copy_buffer(this, src_buffer, dst_buffer, buffer_size)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_buffer), intent(in), value :: src_buffer, dst_buffer
    type(vk_device_size), intent(in), value :: buffer_size
    type(vk_command_buffer), target :: command_buffer
    type(vk_buffer_copy), target :: copy_region

    command_buffer = this%begin_single_time_commands()

    copy_region%src_offset%data = 0
    copy_region%dst_offset%data = 0
    copy_region%size = buffer_size

    call vk_cmd_copy_buffer(command_buffer, src_buffer, dst_buffer, 1, c_loc(copy_region))

    call this%end_single_time_commands(command_buffer)
  end subroutine vk_driver_copy_buffer


  subroutine vk_driver_create_index_buffer(this, indices)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int32_t), dimension(:) :: indices
    type(vk_device_size) :: buffer_size
    type(vk_buffer) :: staging_buffer
    type(vk_device_memory) :: staging_buffer_memory
    ! void *
    type(c_ptr) :: data

    buffer_size%data = sizeof(indices(1)) * size(indices)

    call this%create_buffer(buffer_size, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, ior(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, VK_MEMORY_PROPERTY_HOST_COHERENT_BIT), staging_buffer, staging_buffer_memory)
    if (vk_map_memory(this%logical_device, staging_buffer_memory, vk_device_size(0_8), buffer_size, 0, data) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to map index buffer memory."
    end if
    call totally_not_memcpy_indices(data, indices)
    call vk_unmap_memory(this%logical_device, staging_buffer_memory)

    call this%create_buffer(buffer_size, ior(VK_BUFFER_USAGE_TRANSFER_DST_BIT, VK_BUFFER_USAGE_INDEX_BUFFER_BIT), VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, this%index_buffer, this%index_buffer_memory)
    call this%copy_buffer(staging_buffer, this%index_buffer, buffer_size)

    call vk_destroy_buffer(this%logical_device, staging_buffer, c_null_ptr)
    call vk_free_memory(this%logical_device, staging_buffer_memory, c_null_ptr)
  end subroutine vk_driver_create_index_buffer


  subroutine totally_not_memcpy_indices(data, indices)
    implicit none

    type(c_ptr), intent(in), value :: data
    integer(c_int32_t), dimension(:), intent(in) :: indices
    integer(c_int32_t), dimension(:), pointer :: data_in_buffer

    call c_f_pointer(data, data_in_buffer, [size(indices)])
    data_in_buffer = indices
  end subroutine totally_not_memcpy_indices


  subroutine vk_driver_create_uniform_buffers(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int64_t) :: i
    type(vk_device_size) :: buffer_size
    type(vk_buffer), pointer :: buffer_pointer
    type(vk_device_memory), pointer :: buffer_memory_pointer
    type(c_ptr) :: mapped_buffer_ptr

    buffer_size = vk_device_size(sizeof(uniform_buffer_object()))

    this%uniform_buffers = new_vec(sizeof(vk_buffer()), this%MAX_FRAMES_IN_FLIGHT)
    call this%uniform_buffers%resize(this%MAX_FRAMES_IN_FLIGHT, vk_buffer())

    this%uniform_buffers_memory = new_vec(sizeof(vk_device_memory()), this%MAX_FRAMES_IN_FLIGHT)
    call this%uniform_buffers_memory%resize(this%MAX_FRAMES_IN_FLIGHT, vk_device_memory())

    this%uniform_buffers_mapped = new_vec(buffer_size%data, this%MAX_FRAMES_IN_FLIGHT)
    call this%uniform_buffers_mapped%resize(this%MAX_FRAMES_IN_FLIGHT, c_null_ptr)

    do i = 1,this%MAX_FRAMES_IN_FLIGHT

      call c_f_pointer(this%uniform_buffers%get(i), buffer_pointer)
      call c_f_pointer(this%uniform_buffers_memory%get(i), buffer_memory_pointer)

      call this%create_buffer(buffer_size, VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, ior(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, VK_MEMORY_PROPERTY_HOST_COHERENT_BIT), buffer_pointer, buffer_memory_pointer)

      if (vk_map_memory(this%logical_device, buffer_memory_pointer, vk_device_size(0_8), buffer_size, 0, mapped_buffer_ptr) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to map uniform buffer memory."
      end if
      ! We got the mapped buffer memory location, set it in the vector. This is an awkard way to do this but my brain is too fried to think about a better way.
      call this%uniform_buffers_mapped%set(i, mapped_buffer_ptr)
    end do
  end subroutine vk_driver_create_uniform_buffers


  subroutine vk_driver_create_descriptor_pool(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_descriptor_pool_size), target :: pool_size
    type(vk_descriptor_pool_create_info), target :: pool_info

    pool_size%type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
    pool_size%descriptor_count = int(this%MAX_FRAMES_IN_FLIGHT)

    pool_info%s_type = VK_STRUCTURE_TYPE%DESCRIPTOR_POOL_CREATE_INFO
    pool_info%pool_size_count = 1
    pool_info%p_pool_sizes = c_loc(pool_size)
    pool_info%max_sets = int(this%MAX_FRAMES_IN_FLIGHT)

    if (vk_create_descriptor_pool(this%logical_device, c_loc(pool_info), c_null_ptr, this%descriptor_pool) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create descriptor pool."
    end if
  end subroutine vk_driver_create_descriptor_pool


  subroutine vk_driver_create_descriptor_sets(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! Vk DescriptorSetLayout
    type(vec) :: layouts
    type(vk_descriptor_set_allocate_info), target :: alloc_info
    integer(c_int64_t) :: i
    type(vk_descriptor_buffer_info), target :: buffer_info
    type(vk_buffer), pointer :: buffer_pointer
    type(vk_write_descriptor_set), target :: descriptor_write
    type(vk_descriptor_set), pointer :: descriptor_pointer

    layouts = new_vec(sizeof(this%descriptor_set_layout), this%MAX_FRAMES_IN_FLIGHT)
    call layouts%resize(this%MAX_FRAMES_IN_FLIGHT, this%descriptor_set_layout)

    alloc_info%s_type = VK_STRUCTURE_TYPE%DESCRIPTOR_SET_ALLOCATE_INFO
    alloc_info%descriptor_pool = this%descriptor_pool
    alloc_info%descriptor_set_count = int(this%MAX_FRAMES_IN_FLIGHT)
    alloc_info%p_set_layouts = layouts%get(1_8)

    this%descriptor_sets = new_vec(sizeof(vk_descriptor_set()), this%MAX_FRAMES_IN_FLIGHT)
    call this%descriptor_sets%resize(this%MAX_FRAMES_IN_FLIGHT, vk_descriptor_set())

    if (vk_allocate_descriptor_sets(this%logical_device, c_loc(alloc_info), this%descriptor_sets%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate descriptor sets."
    end if

    ! Don't need this no more.
    call layouts%destroy()

    do i = 1,this%MAX_FRAMES_IN_FLIGHT
      call c_f_pointer(this%uniform_buffers%get(i), buffer_pointer)

      buffer_info%buffer = buffer_pointer
      buffer_info%offset = vk_device_size(0)
      buffer_info%range = vk_device_size(sizeof(uniform_buffer_object()))

      call c_f_pointer(this%descriptor_sets%get(i), descriptor_pointer)

      descriptor_write%s_type = VK_STRUCTURE_TYPE%WRITE_DESCRIPTOR_SET
      descriptor_write%dst_set = descriptor_pointer
      descriptor_write%dst_binding = 0
      descriptor_write%dst_array_element = 0
      descriptor_write%descriptor_type = VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER
      descriptor_write%descriptor_count = 1
      descriptor_write%p_buffer_info = c_loc(buffer_info)
      descriptor_write%p_image_info = c_null_ptr
      descriptor_write%p_texel_buffer_view = c_null_ptr

      call vk_update_descriptor_sets(this%logical_device, 1, c_loc(descriptor_write), 0, c_null_ptr)
    end do
  end subroutine vk_driver_create_descriptor_sets


  subroutine vk_driver_create_command_buffers(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_command_buffer_allocate_info), target :: allocate_info

    this%command_buffers = new_vec(sizeof(VK_NULL_HANDLE), this%MAX_FRAMES_IN_FLIGHT)
    call this%command_buffers%resize(this%MAX_FRAMES_IN_FLIGHT, VK_NULL_HANDLE)

    allocate_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_ALLOCATE_INFO
    allocate_info%command_pool = this%command_pool
    allocate_info%level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
    allocate_info%command_buffer_count = int(this%MAX_FRAMES_IN_FLIGHT, c_int32_t)

    if (vk_allocate_command_buffers(this%logical_device, c_loc(allocate_info), this%command_buffers%get(1_8)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate command buffers."
    end if
  end subroutine vk_driver_create_command_buffers


  subroutine vk_driver_create_sync_objects(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_semaphore_create_info), target :: semaphore_create_info
    type(vk_fence_create_info), target :: fence_create_info
    integer(c_int64_t) :: i
    type(vk_semaphore), pointer :: semaphore_pointer
    type(vk_fence), pointer :: fence_pointer

    this%image_available_semaphores = new_vec(sizeof(VK_NULL_HANDLE), this%MAX_FRAMES_IN_FLIGHT)
    call this%image_available_semaphores%resize(this%MAX_FRAMES_IN_FLIGHT, VK_NULL_HANDLE)

    this%render_finished_semaphores = new_vec(sizeof(VK_NULL_HANDLE), this%MAX_FRAMES_IN_FLIGHT)
    call this%render_finished_semaphores%resize(this%MAX_FRAMES_IN_FLIGHT, VK_NULL_HANDLE)

    this%in_flight_fences = new_vec(sizeof(VK_NULL_HANDLE), this%MAX_FRAMES_IN_FLIGHT)
    call this%in_flight_fences%resize(this%MAX_FRAMES_IN_FLIGHT, VK_NULL_HANDLE)

    semaphore_create_info%s_type = VK_STRUCTURE_TYPE%SEMAPHORE_CREATE_INFO

    fence_create_info%s_type = VK_STRUCTURE_TYPE%FENCE_CREATE_INFO
    fence_create_info%flags = VK_FENCE_CREATE_SIGNALED_BIT

    do i = 1,this%MAX_FRAMES_IN_FLIGHT
      call c_f_pointer(this%image_available_semaphores%get(i), semaphore_pointer)
      if (vk_create_semaphore(this%logical_device, c_loc(semaphore_create_info), c_null_ptr, semaphore_pointer) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to create image available semaphore"
      end if

      call c_f_pointer(this%render_finished_semaphores%get(i), semaphore_pointer)
      if (vk_create_semaphore(this%logical_device, c_loc(semaphore_create_info), c_null_ptr, semaphore_pointer) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to create render finished semaphore"
      end if

      call c_f_pointer(this%in_flight_fences%get(i), fence_pointer)
      if (vk_create_fence(this%logical_device, c_loc(fence_create_info), c_null_ptr, fence_pointer) /= VK_SUCCESS) then
        error stop "[Vulkan] Error: Failed to create in flight fence"
      end if
    end do
  end subroutine vk_driver_create_sync_objects



  !* Implementation note: indices_size needs to be baked into the hashmap.
  !* It is currently a hackjob.
  !! TODO: break this up into [start | do things | submit ]
  subroutine vk_driver_draw_frame(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    ! uint32_t
    integer(c_int32_t), target :: image_index
    type(vk_submit_info), target :: submit_info
    ! Vk Semaphore[]
    type(vk_semaphore), dimension(1), target :: wait_semaphores
    ! VkPipelineStageFlags[]
    integer(c_int32_t), dimension(1), target :: wait_stages
    ! Vk Semaphore[]
    type(vk_semaphore), dimension(1), target :: signal_semaphores
    type(vk_present_info_khr), target :: present_info
    type(vk_swapchain_khr), dimension(1), target :: swapchains
    type(vk_fence), pointer :: fence_pointer
    type(vk_semaphore), pointer :: semaphore_pointer
    type(vk_command_buffer), pointer :: command_buffer_pointer
    integer(c_int32_t) :: acquire_result, error_result

    ! -1 is UINT64_MAX, aka, unlimited timeout.
    if (vk_wait_for_fences(this%logical_device, 1, this%in_flight_fences%get(this%current_frame), VK_TRUE, -1_8) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait for fences."
    end if

    call c_f_pointer(this%image_available_semaphores%get(this%current_frame), semaphore_pointer)
    acquire_result = vk_acquire_next_image_khr(this%logical_device, this%swapchain, -1_8, semaphore_pointer, vk_fence(VK_NULL_HANDLE), image_index)

    if (vk_reset_fences(this%logical_device, 1, this%in_flight_fences%get(this%current_frame)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to reset in flight fence."
    end if

    ! We now translate this to Fortran indexing.
    ! todo: make this into a helper function.
    image_index = image_index + 1

    call c_f_pointer(this%command_buffers%get(this%current_frame), command_buffer_pointer)
    if (vk_reset_command_buffer(command_buffer_pointer, 0) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Faield to reset command buffer."
    end if

    call this%record_command_buffer(command_buffer_pointer, image_index)

    submit_info%s_type = VK_STRUCTURE_TYPE%SUBMIT_INFO

    call c_f_pointer(this%image_available_semaphores%get(this%current_frame), semaphore_pointer)
    wait_semaphores = [semaphore_pointer]

    wait_stages = [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT]

    call this%update_uniform_buffer(this%current_frame)

    submit_info%wait_semaphore_count = 1
    submit_info%p_wait_semaphores = c_loc(wait_semaphores)
    submit_info%p_wait_dst_stage_mask = c_loc(wait_stages)
    submit_info%command_buffer_count = 1
    submit_info%p_command_buffers = c_loc(command_buffer_pointer)

    call c_f_pointer(this%render_finished_semaphores%get(this%current_frame), semaphore_pointer)
    signal_semaphores = [semaphore_pointer]
    submit_info%signal_semaphore_count = 1
    submit_info%p_signal_semaphores = c_loc(signal_semaphores)

    call c_f_pointer(this%in_flight_fences%get(this%current_frame), fence_pointer)
    if (vk_queue_submit(this%graphics_queue, 1, c_loc(submit_info), fence_pointer) /= VK_SUCCESS) then
      error stop
    end if

    present_info%s_type = VK_STRUCTURE_TYPE%PRESENT_INFO_KHR

    present_info%wait_semaphore_count = 1
    present_info%p_wait_semaphores = c_loc(signal_semaphores)

    swapchains = [this%swapchain]

    ! Now move it back.
    ! todo: this needs to be removed!
    image_index = image_index - 1

    present_info%swapchain_count = 1
    present_info%p_swapchains = c_loc(swapchains)
    present_info%p_image_indices = c_loc(image_index)

    present_info%p_results = c_null_ptr

    error_result = vk_queue_present_khr(this%present_queue, c_loc(present_info))
    if (error_result /= VK_SUCCESS .and. error_result /= VK_SUBOPTIMAL_KHR) then
      print*,error_result
      error stop "[Vulkan] Error: Failed to present queue."
    end if

    ! The Vulkan tutorial is very vague on this part.
    ! If you're reading this, this part was supposed to be split up like so lol.
    if (acquire_result == VK_ERROR_OUT_OF_DATE_KHR .or. acquire_result == VK_SUBOPTIMAL_KHR .or. this%framebuffer_resized) then
      call this%recreate_swapchain()
      this%framebuffer_resized = .false.
      print*,"recreating swap chain"
      ! This early return prevents a deadlock.
      return
    else if (acquire_result /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to aqcuire next swapchain image."
    end if

    ! Tick and cycle frames.
    this%current_frame = mod(this%current_frame, this%MAX_FRAMES_IN_FLIGHT) + 1
  end subroutine vk_driver_draw_frame


  !* Implementation note: indices_size needs to be baked into the hashmap.
  !* It is currently a hackjob.
  subroutine vk_driver_record_command_buffer(this, command_buffer, image_index)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_command_buffer), intent(in), value :: command_buffer
    ! uint32_t
    integer(c_int32_t), intent(in), value :: image_index
    type(vk_command_buffer_begin_info), target :: begin_info
    type(vk_render_pass_begin_info), target :: render_pass_info
    type(vk_framebuffer), pointer :: framebuffer
    type(vk_clear_color_value_f32), target :: clear_color
    type(vk_viewport), target :: viewport
    type(vk_rect_2d), target :: scissor
    type(vk_buffer), dimension(1), target :: vertex_buffers
    type(vk_device_size), dimension(1), target :: offsets

    begin_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_BEGIN_INFO
    begin_info%flags = 0
    begin_info%p_inheritence_info = c_null_ptr

    if (vk_begin_command_buffer(command_buffer, c_loc(begin_info)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to begin recording command buffer."
    end if

    render_pass_info%s_type = VK_STRUCTURE_TYPE%RENDER_PASS_BEGIN_INFO
    render_pass_info%render_pass = this%render_pass
    call c_f_pointer(this%swapchain_framebuffers%get(int(image_index, c_int64_t)), framebuffer)
    render_pass_info%framebuffer = framebuffer
    render_pass_info%render_area%offset%x = 0
    render_pass_info%render_area%offset%y = 0
    render_pass_info%render_area%extent = this%swapchain_extent

    clear_color%data = [0.0, 0.0, 0.0, 1.0]
    render_pass_info%clear_value_count = 1
    render_pass_info%p_clear_values = c_loc(clear_color)

    call vk_cmd_begin_render_pass(command_buffer, c_loc(render_pass_info), VK_SUBPASS_CONTENTS_INLINE)

    call vk_cmd_bind_pipeline(command_buffer, VK_PIPELINE_BIND_POINT_GRAPHICS, this%graphics_pipeline)

    vertex_buffers = [this%vertex_buffer]
    offsets = [vk_device_size(0_8)]

    call vk_cmd_bind_vertex_buffers(command_buffer, 0, 1, c_loc(vertex_buffers), c_loc(offsets))

    call vk_cmd_bind_index_buffer(command_buffer, this%index_buffer, vk_device_size(0_8), VK_INDEX_TYPE_UINT32)

    viewport%x = 0.0
    viewport%y = 0.0
    viewport%width = this%swapchain_extent%width
    viewport%height = this%swapchain_extent%height
    viewport%min_depth = 0.0
    viewport%max_depth = 1.0

    call vk_cmd_set_viewport(command_buffer, 0, 1, c_loc(viewport))

    scissor%offset%x = 0
    scissor%offset%y = 0
    scissor%extent = this%swapchain_extent

    call vk_cmd_set_scissor(command_buffer, 0, 1, c_loc(scissor))

    call vk_cmd_bind_descriptor_sets(command_buffer, VK_PIPELINE_BIND_POINT_GRAPHICS, this%pipeline_layout, 0, 1, this%descriptor_sets%get(this%current_frame), 0, c_null_ptr)

    ! call vk_cmd_draw(command_buffer, 3, 1, 0, 0)
    call vk_cmd_draw_indexed(command_buffer, this%indices_size, 1, 0, 0, 0)

    call vk_cmd_end_render_pass(command_buffer)

    if (vk_end_command_buffer(command_buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to record command buffer."
    end if
  end subroutine vk_driver_record_command_buffer


  subroutine vk_driver_update_uniform_buffer(this, current_image)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int64_t), intent(in), value :: current_image
    type(uniform_buffer_object) :: ubo
    type(c_ptr), pointer :: raw_c_ptr_ptr
    type(uniform_buffer_object), pointer :: ubo_pointer

    time = time + 0.0005

    call ubo%camera_matrix%identity()
    call ubo%object_matrix%identity()

    call ubo%camera_matrix%perspective_left_handed(to_radians_f32(60.0), real(this%swapchain_extent%width) / real(this%swapchain_extent%height), 0.01, 1000.0, .true.)

    call ubo%object_matrix%translate(cos(time / 1.7), sin(time / 3.0), 3.0)
    call ubo%object_matrix%rotate_y(time)

    call c_f_pointer(this%uniform_buffers_mapped%get(current_image), raw_c_ptr_ptr)
    call c_f_pointer(raw_c_ptr_ptr, ubo_pointer)

    ! We have memcpy at home.
    ubo_pointer%camera_matrix = ubo%camera_matrix
    ubo_pointer%object_matrix = ubo%object_matrix
  end subroutine vk_driver_update_uniform_buffer


  subroutine vk_driver_recreate_swapchain(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int32_t) :: width, height

    if (vk_device_wait_idle(this%logical_device) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait for logical device."
    end if

    call glfw_get_framebuffer_size(width, height)
    do while (width == 0 .or. height == 0)
      print*,"waiting"
      call glfw_get_framebuffer_size(width, height)
      call glfw_wait_events()
    end do

    call this%clean_up_swapchain()

    call this%create_swapchain()
    call this%create_image_views()
    call this%create_framebuffers()
  end subroutine vk_driver_recreate_swapchain


  subroutine vk_driver_create_texture_image(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int32_t) :: width, height, channels
    integer(1), dimension(:), allocatable :: texture_data
    type(vk_device_size) :: image_size
    type(vk_buffer) :: staging_buffer
    type(vk_device_memory) :: staging_buffer_memory
    type(c_ptr) :: raw_c_ptr

    texture_data = stbi_load("textures/fortran_logo_512x512.png", width, height, channels, 4)

    if (.not. allocated(texture_data)) then
      error stop "[Vulkan] Error: Failed to load texture."
    end if

    image_size%data = width * height * 4

    call this%create_buffer(image_size, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, ior(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, VK_MEMORY_PROPERTY_HOST_COHERENT_BIT), staging_buffer, staging_buffer_memory)

    if (vk_map_memory(this%logical_device, staging_buffer_memory, vk_device_size(0), image_size, 0, raw_c_ptr) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to map memory."
    end if
    call totally_not_memcpy_texture(raw_c_ptr, texture_data)
    call vk_unmap_memory(this%logical_device, staging_buffer_memory)

    call this%create_image(width, height, VK_FORMAT_R8G8B8A8_SRGB, VK_IMAGE_TILING_OPTIMAL, ior(VK_IMAGE_USAGE_TRANSFER_DST_BIT, VK_IMAGE_USAGE_SAMPLED_BIT), VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT, this%texture_image, this%texture_image_memory)

    call this%transition_image_layout(this%texture_image, vk_format(VK_FORMAT_R8G8B8A8_SRGB), VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL)

    call this%copy_buffer_to_image(staging_buffer, this%texture_image, width, height)

    call this%transition_image_layout(this%texture_image, vk_format(VK_FORMAT_R8G8B8A8_SRGB), VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)

    call vk_destroy_buffer(this%logical_device, staging_buffer, c_null_ptr)

    call vk_free_memory(this%logical_device, staging_buffer_memory, c_null_ptr)

  end subroutine vk_driver_create_texture_image


  subroutine vk_driver_create_image(this, width, height, format, tiling, usage, properties, image, image_memory)
    implicit none

    class(vk_driver), intent(inout) :: this
    integer(c_int32_t), intent(in), value :: width, height, format, tiling, usage, properties
    type(vk_image), intent(inout) :: image
    type(vk_device_memory), intent(inout) :: image_memory
    type(vk_image_create_info), target :: image_info
    type(vk_memory_requirements) :: mem_requirements
    type(vk_memory_allocate_info), target :: alloc_info

    image_info%s_type = VK_STRUCTURE_TYPE%IMAGE%CREATE_INFO
    image_info%image_type = VK_IMAGE_TYPE_2D
    image_info%extent%width = width
    image_info%extent%height = height
    image_info%extent%depth = 1
    image_info%mip_levels = 1
    image_info%array_layers = 1
    image_info%format = format
    image_info%tiling = tiling
    image_info%initial_layout = VK_IMAGE_LAYOUT_UNDEFINED
    image_info%usage = usage
    image_info%sharing_mode = VK_SHARING_MODE_EXCLUSIVE
    image_info%samples = VK_SAMPLE_COUNT_1_BIT
    image_info%flags = 0

    if (vk_create_image(this%logical_device, c_loc(image_info), c_null_ptr, image) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create image."
    end if

    call vk_get_image_memory_requirements(this%logical_device, image, mem_requirements)

    alloc_info%s_type = VK_STRUCTURE_TYPE%MEMORY%ALLOCATE_INFO
    alloc_info%allocation_size = mem_requirements%size
    alloc_info%memory_type_index = this%find_memory_type(mem_requirements%memory_type_bits, properties)

    if (vk_allocate_memory(this%logical_device, c_loc(alloc_info), c_null_ptr, image_memory) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate memory."
    end if

    if (vk_bind_image_memory(this%logical_device, image, image_memory, vk_device_size(0)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to bind image memory."
    end if
  end subroutine vk_driver_create_image


  subroutine totally_not_memcpy_texture(data, texture_data)
    implicit none

    type(c_ptr), intent(in), value :: data
    integer(1), dimension(:), intent(in) :: texture_data
    integer(1), dimension(:), pointer :: data_in_buffer

    call c_f_pointer(data, data_in_buffer, [size(texture_data)])
    data_in_buffer = texture_data
  end subroutine totally_not_memcpy_texture


  function vk_driver_begin_single_time_commands(this) result(command_buffer)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_command_buffer), target :: command_buffer
    type(vk_command_buffer_allocate_info), target :: alloc_info
    type(vk_command_buffer_begin_info), target :: begin_info

    alloc_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_ALLOCATE_INFO
    alloc_info%level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
    alloc_info%command_pool = this%command_pool
    alloc_info%command_buffer_count = 1

    if (vk_allocate_command_buffers(this%logical_device, c_loc(alloc_info), c_loc(command_buffer)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to allocate command buffers."
    end if

    begin_info%s_type = VK_STRUCTURE_TYPE%COMMAND_BUFFER_BEGIN_INFO
    begin_info%flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT

    if (vk_begin_command_buffer(command_buffer, c_loc(begin_info)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to begin command buffer."
    end if
  end function vk_driver_begin_single_time_commands


  subroutine vk_driver_end_single_time_commands(this, command_buffer)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_command_buffer), intent(in), value, target :: command_buffer
    type(vk_submit_info), target :: submit_info

    if (vk_end_command_buffer(command_buffer) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to end command buffer."
    end if

    submit_info%s_type = VK_STRUCTURE_TYPE%SUBMIT_INFO
    submit_info%command_buffer_count = 1
    submit_info%p_command_buffers = c_loc(command_buffer)

    if (vk_queue_submit(this%graphics_queue, 1, c_loc(submit_info), vk_fence(VK_NULL_HANDLE)) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to submit queue."
    end if

    if (vk_queue_wait_idle(this%graphics_queue) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to wait idle for graphics queue."
    end if

    call vk_free_command_buffers(this%logical_device, this%command_pool, 1, c_loc(command_buffer))
  end subroutine vk_driver_end_single_time_commands


  ! todo: figure out why format is a dummy variable
  subroutine vk_driver_transition_image_layout(this, image, format, old_layout, new_layout)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_image), intent(in), value :: image
    type(vk_format), intent(in), value :: format
    integer(c_int32_t), intent(in), value :: old_layout, new_layout
    type(vk_command_buffer) :: command_buffer
    type(vk_image_memory_barrier), target :: barrier
    integer(c_int32_t) :: source_stage, destination_stage

    command_buffer = this%begin_single_time_commands()

    barrier%s_type = VK_STRUCTURE_TYPE%IMAGE%MEMORY_BARRIER
    barrier%old_layout = old_layout
    barrier%new_layout = new_layout
    barrier%src_queue_family_index = VK_QUEUE_FAMILY_IGNORED
    barrier%dst_queue_family_index = VK_QUEUE_FAMILY_IGNORED
    barrier%image = image
    barrier%subresource_range%aspect_mask = VK_IMAGE_ASPECT_COLOR_BIT
    barrier%subresource_range%base_mip_level = 0
    barrier%subresource_range%level_count = 1
    barrier%subresource_range%base_array_layer = 0
    barrier%subresource_range%layer_count = 1

    if (old_layout == VK_IMAGE_LAYOUT_UNDEFINED .and. new_layout == VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL) then
      barrier%src_access_mask = 0
      barrier%dst_access_mask = VK_ACCESS_TRANSFER_WRITE_BIT

      source_stage = VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT
      destination_stage = VK_PIPELINE_STAGE_TRANSFER_BIT

    else if (old_layout == VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL .and. new_layout == VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL) then
      barrier%src_access_mask = VK_ACCESS_TRANSFER_WRITE_BIT
      barrier%dst_access_mask = VK_ACCESS_SHADER_READ_BIT

      source_stage = VK_PIPELINE_STAGE_TRANSFER_BIT
      destination_stage = VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT
    else
      error stop "[Vulkan] Error: Unsupported layout transistion."
    end if

    call vk_cmd_pipeline_barrier( &
      command_buffer, &
      source_stage, destination_stage, &
      0, &
      0, c_null_ptr, &
      0, c_null_ptr, &
      1, c_loc(barrier) &
      )

    call this%end_single_time_commands(command_buffer)
  end subroutine vk_driver_transition_image_layout


  subroutine vk_driver_copy_buffer_to_image(this, buffer, image, width, height)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_buffer), intent(in), value :: buffer
    type(vk_image), intent(in), value :: image
    integer(c_int32_t), intent(in), value :: width, height
    type(vk_command_buffer) :: command_buffer
    type(vk_buffer_image_copy), target :: region

    command_buffer = this%begin_single_time_commands()

    region%buffer_offset = vk_device_size(0)
    region%buffer_row_length = 0
    region%buffer_image_height = 0

    region%image_subresource%aspect_mask = VK_IMAGE_ASPECT_COLOR_BIT
    region%image_subresource%mip_level = 0
    region%image_subresource%base_array_layer = 0
    region%image_subresource%layer_count = 1

    region%image_offset%x = 0
    region%image_offset%y = 0
    region%image_offset%z = 0

    region%image_extent%width = width
    region%image_extent%height = height
    region%image_extent%depth = 1

    call vk_cmd_copy_buffer_to_image(command_buffer, buffer, image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, c_loc(region))

    call this%end_single_time_commands(command_buffer)
  end subroutine vk_driver_copy_buffer_to_image


  subroutine vk_driver_create_texture_image_view(this)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_image_view_create_info), target :: view_info

    view_info%s_type = VK_STRUCTURE_TYPE%IMAGE%VIEW_CREATE_INFO
    view_info%image = this%texture_image
    view_info%view_type = VK_IMAGE_VIEW_TYPE_2D
    view_info%format = vk_format(VK_FORMAT_R8G8B8A8_SRGB)
    view_info%subresource_range%aspect_mask = VK_IMAGE_ASPECT_COLOR_BIT
    view_info%subresource_range%base_mip_level = 0
    view_info%subresource_range%level_count = 1
    view_info%subresource_range%base_array_layer = 0
    view_info%subresource_range%layer_count = 1

    if (vk_create_image_view(this%logical_device, c_loc(view_info), c_null_ptr, this%texture_image_view) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create image view."
    end if
  end subroutine vk_driver_create_texture_image_view


  function vk_driver_create_image_view(this, image, format) result(image_view)
    implicit none

    class(vk_driver), intent(inout) :: this
    type(vk_image), intent(in), value :: image
    type(vk_format), intent(in), value :: format
    type(vk_image_view) :: image_view
    type(vk_image_view_create_info), target :: view_info

    view_info%s_type = VK_STRUCTURE_TYPE%IMAGE%VIEW_CREATE_INFO
    view_info%image = image
    view_info%view_type = VK_IMAGE_VIEW_TYPE_2D
    view_info%format = format
    view_info%subresource_range%aspect_mask = VK_IMAGE_ASPECT_COLOR_BIT
    view_info%subresource_range%base_mip_level = 0
    view_info%subresource_range%level_count = 1
    view_info%subresource_range%base_array_layer = 0
    view_info%subresource_range%layer_count = 1

    if (vk_create_image_view(this%logical_device, c_loc(view_info), c_null_ptr, image_view) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to create image view."
    end if
  end function vk_driver_create_image_view


end module vulkan_driver
