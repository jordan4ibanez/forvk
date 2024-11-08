module vulkan_driver
  use, intrinsic :: iso_c_binding
  use :: glfw
  use :: string_f90
  use :: vector
  use :: forvulkan
  use :: forvulkan_parameters
  !? These are imported in the order of the steps this takes.
  use :: vulkan_driver_create_base
  use :: vulkan_driver_create_extensions
  use :: vulkan_driver_create_validation_layers
  use :: vulkan_driver_create_instance
  use :: vulkan_driver_create_debug_messenger
  use :: vulkan_driver_device_selection
  implicit none

  ! https://github.com/KhronosGroup/Vulkan-Headers/blob/main/include/vulkan/vulkan_core.h

  ! Treating this thing as a class to follow the vulkan tutorial.
  ! todo: in formine this will have a pointer struct which inherits from a base class, to direct traffic flow to these functions.
  !
  ! todo: this has a lot of memory leaks which will need to be tested with valgrind to fix.


  ! VkInstance
  integer(c_int64_t), target :: vulkan_instance = VK_NULL_HANDLE

  ! VkDebugUtilsMessengerEXT
  integer(c_int64_t), target :: debug_messenger = VK_NULL_HANDLE

  ! VkPhysicalDevice
  integer(c_int64_t), target :: physical_device = VK_NULL_HANDLE

  ! Controls debugging output.
  logical(c_bool), parameter :: DEBUG_MODE = .true.


contains

  subroutine vulkan_run()
    implicit none

    call init_vulkan()
    call main_loop()
    call clean_up()
  end subroutine vulkan_run


!* INITIALIZATION. ====================================================================


  subroutine init_vulkan()
    implicit none

    ! VkApplicationInfo
    type(vk_application_info), pointer :: app_info
    ! VkInstanceCreateInfo
    type(vk_instance_create_info), pointer :: vulkan_create_info
    ! const char **
    type(vec) :: required_extensions
    ! const char **
    type(vec) :: required_validation_layers
    type(vk_debug_utils_messenger_create_info_ext), pointer :: debug_messenger_create_info
    !* Note: this will go out of scope after this. We only need it for pre-initialization.
    type(vk_debug_utils_messenger_create_info_ext) :: before_init_messenger_create_info

    !? This is how to get from these vectors. (char ** array underneath)
    !? do i = 1,int(validation_layers%size())
    !   !! NOTICE: Redirecting the pointer with c_f_pointer here!
    !?   call c_f_pointer(validation_layers%get(int(i, c_int64_t)), raw_c_ptr_ptr)
    !?   required_layer => string_from_c(raw_c_ptr_ptr)
    !?   print*,required_layer
    !? end do

    call create_glfw()

    call create_app_info(app_info)

    call create_required_extensions(required_extensions, DEBUG_MODE)

    call ensure_extensions_present(required_extensions)

    call create_required_validation_layers(required_validation_layers, DEBUG_MODE)

    call ensure_validation_layer_support(required_validation_layers, DEBUG_MODE)

    call create_vulkan_instance_create_info(vulkan_create_info, app_info, required_extensions, required_validation_layers, before_init_messenger_create_info, DEBUG_MODE)

    call create_vulkan_instance(vulkan_create_info, vulkan_instance)

    call setup_debug_messenger(debug_messenger_create_info, vulkan_instance, debug_messenger, DEBUG_MODE)

    ! TODO: THIS SHOULD BE BROKEN UP INTO ANOTHER FUNCTION THAT SELECTS PHYSICAL DEVICE!
    ! TODO: OR, MAKE A GREEN SPACER INSIDE THE FILE TO DENOTE WHERE PHYSICAL DEVICE SELECTION STARTS.
    !! PROBABLY SHOULD DO THE SAME THING WHICH EACH STEP IN INITIALIZATION !!

    call pick_physical_device(vulkan_instance, physical_device)

    call blah()

    ! todo: deallocate any pointers inside.
    deallocate(app_info)
    deallocate(vulkan_create_info)
    ! todo: destroy the vectors!
  end subroutine init_vulkan


  subroutine blah()
    implicit none

    type(forvulkan_queue_family_index) :: a

    a = find_queue_families(physical_device)

  end subroutine blah


  function find_queue_families(device) result(queue_family_index)
    implicit none

    ! VkPhysicalDevice
    integer(c_int64_t), intent(in), value :: device
    type(forvulkan_queue_family_index) :: queue_family_index
    integer(c_int32_t) :: queue_family_count, i
    ! VkQueueFamilyProperties
    type(vec) :: queue_families
    type(vk_queue_family_properties), pointer :: properties

    ! Sniff out those graphics queue families.

    call vk_get_physical_device_queue_family_properties(device, queue_family_count, c_null_ptr)

    allocate(properties)
    queue_families = new_vec(sizeof(properties), int(queue_family_count, c_int64_t))
    call queue_families%resize(int(queue_family_count, c_int64_t), properties)
    deallocate(properties)

    call vk_get_physical_device_queue_family_properties(device, queue_family_count, queue_families%get(1_8))

    do i = 1, queue_family_count
      ! We're just straight shooting this right from C into Fortran.
      call c_f_pointer(queue_families%get(int(i, c_int64_t)), properties)

      if (iand(properties%queue_flags, VK_QUEUE_GRAPHICS_BIT) == VK_TRUE) then
        queue_family_index%has_value = .true.
        queue_family_index%graphics_family = i
        exit
      end if
    end do
  end function find_queue_families


!* MAIN LOOP. ====================================================================


  subroutine main_loop()
    implicit none

    ! do while(.not. glfw_window_should_close())
    !   call glfw_poll_events()
    ! end do

  end subroutine main_loop


!* CLEAN UP. ====================================================================

  subroutine clean_up()
    implicit none

    if (DEBUG_MODE) then
      call forvulkan_destroy_debug_utils_messenger_ext(vulkan_instance, debug_messenger, c_null_ptr)
    end if

    print"(A)","[Vulkan]: Destroying instance."

    call vk_destroy_instance(vulkan_instance, c_null_ptr)

    call glfw_destroy_window()

    call glfw_terminate()
  end subroutine clean_up


end module vulkan_driver
