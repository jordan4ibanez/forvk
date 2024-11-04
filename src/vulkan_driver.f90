module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: forvk
  use :: forvk_parameters
  use :: glfw
  use :: string_f90
  use :: vector
  implicit none

  ! https://github.com/KhronosGroup/Vulkan-Headers/blob/main/include/vulkan/vulkan_core.h

  ! Treating this thing as a class to follow the vulkan tutorial.
  ! todo: in formine this will have a pointer struct which inherits from a base class, to direct traffic flow to these functions.
  !
  ! todo: this has a lot of memory leaks which will need to be tested with valgrind to fix.


  ! VkInstance
  integer(c_int64_t), target :: vulkan_instance = 0

  ! VkDebugUtilsMessengerEXT
  integer(c_int64_t), target :: debug_messenger = 0


  logical(c_bool), parameter :: DEBUG_MODE = .true.


contains

  subroutine vulkan_run()
    implicit none

    call init_vulkan()
    call main_loop()
    call clean_up()
  end subroutine vulkan_run


  subroutine init_vulkan()
    implicit none

    type(vk_application_info), pointer :: app_info
    type(vk_instance_create_info), pointer :: vulkan_create_info
    ! const char **
    type(vec) :: required_extensions
    ! const char **
    type(vec) :: required_validation_layers

    !? This is how to get from these vectors. (char ** array underneath)
    !? do i = 1,int(validation_layers%size())
    !   !! NOTICE: Redirecting the pointer with c_f_pointer here!
    !?   call c_f_pointer(validation_layers%get(int(i, c_int64_t)), raw_c_ptr_ptr)
    !?   required_layer => string_from_c(raw_c_ptr_ptr)
    !?   print*,required_layer
    !? end do

    call create_glfw()

    call create_app_info(app_info)

    call create_required_extensions(required_extensions)

    call ensure_extensions_present(required_extensions)

    call create_required_validation_layers(required_validation_layers)

    call ensure_validation_layer_support(required_validation_layers)

    call create_vulkan_instance_create_info(vulkan_create_info, app_info, required_extensions, required_validation_layers)

    call create_vulkan_instance(vulkan_create_info)

    call setup_debug_messenger()

    ! todo: deallocate any pointers inside.
    deallocate(app_info)
    deallocate(vulkan_create_info)

  end subroutine init_vulkan


  subroutine create_glfw()
    implicit none

    if (.not. glfw_init()) then
      error stop "[Vulkan] Error: Failed to initialize GLFW."
    end if

    ! call glfw_window_hint(GLFW_SCALE_FRAMEBUFFER, GLFW_TRUE)
    call glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)
    call glfw_window_hint(GLFW_RESIZABLE, GLFW_FALSE)

    if (.not. glfw_create_window(500, 500, "forvk")) then
      error stop "[Vulkan]: Failed to create window."
    end if
  end subroutine create_glfw


  subroutine create_app_info(app_info)
    implicit none

    type(vk_application_info), intent(inout), pointer :: app_info
    character(len = :, kind = c_char), pointer :: app_name, engine_name

    print"(A)","[Vulkan]: Creating app info."

    allocate(app_info)

    app_info%s_type = VK_STRUCTURE_TYPE%APPLICATION_INFO

    ! todo: this will need a bit of finesse in the future.
    allocate(character(len = 10, kind = c_char) :: app_name)
    app_name = "ForVulkan"//achar(0)

    app_info%p_application_name = c_loc(app_name)
    app_info%application_version = vk_make_api_version(0,1,0,0)

    ! todo: this will need a bit of finesse in the future.
    allocate(character(len = 8, kind = c_char) :: engine_name)
    engine_name = "Formine"//achar(0)

    app_info%p_engine_name = c_loc(engine_name)
    app_info%engine_version = vk_make_api_version(0,1,0,0)
    app_info%api_version = VK_API_VERSION_1_0
  end subroutine create_app_info


  subroutine create_required_extensions(required_extensions)
    implicit none

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
    required_extensions = new_vec(sizeof(c_null_ptr), 0_8)

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

    if (DEBUG_MODE) then
      allocate(character(len = len(VK_EXT_DEBUG_UTILS_EXTENSION_NAME), kind = c_char) :: output)
      output = VK_EXT_DEBUG_UTILS_EXTENSION_NAME
      call required_extensions%push_back(c_loc(output))
    end if
  end subroutine create_required_extensions


  subroutine ensure_extensions_present(required_extensions)
    implicit none

    type(vec), intent(inout) :: required_extensions
    integer(c_int) :: result, extension_count
    type(vec) :: available_extensions_array
    type(vk_extension_properties) :: blank
    integer(c_int) :: i, j, k, prop_length
    type(c_ptr), pointer :: raw_c_ptr_ptr
    type(vk_extension_properties), pointer :: extension_properties
    character(len = :, kind = c_char), pointer :: temp_string_pointer
    character(len = :, kind = c_char), allocatable :: temp
    logical(c_bool) :: found

    print"(A)","[Vulkan]: Gathering available extensions."

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, c_null_ptr)

    if (result /= VK_SUCCESS) then
      error stop "[Vulkan]: Failed to enumrate instance extension properties. Error code ["//int_to_string(result)//"]"
    end if

    available_extensions_array = new_vec(sizeof(blank), int(extension_count, c_int64_t))
    call available_extensions_array%resize(int(extension_count, c_int64_t), blank)

    result = vk_enumerate_instance_extension_properties(c_null_ptr, extension_count, available_extensions_array%get(1_8))

    print"(A)","[Vulkan]: Ensuring required extensions are present."

    ! Iterate all required extensions.

    do j = 1,int(required_extensions%size())

      found = .false.

      call c_f_pointer(required_extensions%get(int(j, c_int64_t)), raw_c_ptr_ptr)
      temp_string_pointer => string_from_c(raw_c_ptr_ptr)

      ! Iterate all available extensions.
      do i = 1,int(extension_count)

        ! Transfer the VkExtensionProperties pointer into Fortran.
        call c_f_pointer(available_extensions_array%get(int(i, c_int64_t)), extension_properties)

        ! Find the length of the character array.
        do k = 1,VK_MAX_EXTENSION_NAME_SIZE
          if (extension_properties%extension_name(k) == achar(0)) then
            prop_length = k - 1
            exit
          end if
        end do

        ! Now copy it into a string.
        allocate(character(len = prop_length, kind = c_char) :: temp)

        do k = 1,prop_length
          temp(k:k) = extension_properties%extension_name(k)
        end do

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

    print"(A)","[Vulkan]: All required extensions are present."
  end subroutine ensure_extensions_present


  subroutine create_required_validation_layers(required_validation_layers)
    implicit none

    ! const char *
    type(vec), intent(inout) :: required_validation_layers
    character(len = :, kind = c_char), pointer :: layer_name

    ! If we're not in debug mode, don't bother with this.
    if (.not. DEBUG_MODE) then
      return
    end if

    ! Create validation layers that we need.

    print"(A)","[Vulkan]: Creating required validation layers."

    layer_name => null()
    required_validation_layers = new_vec(sizeof(c_null_ptr), 0_8)

    allocate(character(len = 28, kind = c_char) :: layer_name)
    layer_name = "VK_LAYER_KHRONOS_validation"//achar(0)
    call required_validation_layers%push_back(c_loc(layer_name))

  end subroutine create_required_validation_layers


  subroutine ensure_validation_layer_support(required_validation_layers)
    implicit none

    ! const char *
    type(vec), intent(inout) :: required_validation_layers
    ! VkLayerProperties
    type(vec) :: available_layer_array
    type(vk_layer_properties), pointer :: layer
    integer(c_int) :: available_layer_count
    logical(c_bool) :: found
    ! char **
    type(c_ptr), pointer :: raw_c_ptr_ptr
    integer(c_int) :: i, j, k, available_layer_name_length
    character(len = :, kind = c_char), pointer :: required_layer, temp


    ! If we're not in debug mode, don't bother with this.
    if (.not. DEBUG_MODE) then
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

        ! Let's get the length of that character array.
        do k = 1,VK_MAX_EXTENSION_NAME_SIZE
          if (layer%layer_name(k) == achar(0)) then
            available_layer_name_length = k - 1
            exit
          end if
        end do

        ! Now copy the character array into a string.
        allocate(character(len = available_layer_name_length, kind = c_char) :: temp)

        do k = 1,available_layer_name_length
          temp(k:k) = layer%layer_name(k)
        end do

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
        error stop "[Vulkan] Error: Did not find required validation layer ["//required_layer//"]"
      end if
    end do

    print"(A)","[Vulkan]: Found all required validation layers."
  end subroutine ensure_validation_layer_support


  subroutine create_vulkan_instance_create_info(vulkan_create_info, app_info, required_extensions, required_validation_layers)
    implicit none

    type(vk_instance_create_info), intent(inout), pointer :: vulkan_create_info
    type(vk_application_info), intent(in), pointer :: app_info
    type(vec), intent(inout) :: required_extensions
    type(vec), intent(inout) :: required_validation_layers

    print"(A)","[Vulkan]: Creating create info."

    allocate(vulkan_create_info)

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
    else
      vulkan_create_info%enabled_layer_count = 0
    end if

    vulkan_create_info%enabled_layer_count = 0
  end subroutine create_vulkan_instance_create_info


  subroutine create_vulkan_instance(vulkan_create_info)
    implicit none

    type(vk_instance_create_info), intent(in), target :: vulkan_create_info
    integer(c_int) :: result

    print"(A)", "[Vulkan]: Creating instance."

    result = vk_create_instance(c_loc(vulkan_create_info), c_null_ptr, vulkan_instance)

    if (result /= VK_SUCCESS) then
      ! Shove driver check in.
      if (result == VK_ERROR_INCOMPATIBLE_DRIVER) then
        error stop "[Vulkan] Error: Failed to create Vulkan instance. Incompatible driver. Error code: ["//int_to_string(result)//"]"
      end if
      error stop "[Vulkan] Error: Failed to create Vulkan instance. Error code: ["//int_to_string(result)//"]"
    end if
  end subroutine create_vulkan_instance


  subroutine setup_debug_messenger()
    implicit none

    type(vk_debug_utils_messenger_create_info_ext), target :: create_info!validation_create_info

    ! Don't need this if we're not in debug mode.
    if (.not. DEBUG_MODE) then
      return
    end if

    print"(A)","[Vulkan]: Setting up debug messenger."

    ! allocate(create_info)
  
    create_info%s_type = VK_STRUCTURE_TYPE%DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT
    create_info%message_severity = or(VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT, or(VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT, VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT))
    create_info%message_type = or(VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT, or(VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT, VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT))
    create_info%pfn_user_callback = c_funloc(debug_callback)
    create_info%p_user_data = c_null_ptr ! Optional.

    if (forvulkan_create_debug_utils_messenger_ext(vulkan_instance, c_loc(create_info), c_null_ptr, debug_messenger) /= VK_SUCCESS) then
      error stop "[Vulkan] Error: Failed to set up debug messenger."
    end if

  end subroutine setup_debug_messenger


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
      print*,"high severity"
    end if

    print"(A)", "[Vulkan] Validation layer: ",p_callback_data%p_message

    vk_bool_32 = VK_FALSE
  end function debug_callback


!* MAIN LOOP. ====================================================================


  subroutine main_loop()
    implicit none

    ! do while(.not. glfw_window_should_close())
    !   call glfw_poll_events()
    ! end do

  end subroutine main_loop

  subroutine clean_up()
    implicit none

    print"(A)","[Vulkan]: Destroying instance."

    call vk_destroy_instance(vulkan_instance, c_null_ptr)

    call glfw_destroy_window()

    call glfw_terminate()
  end subroutine clean_up


end module vulkan_driver
