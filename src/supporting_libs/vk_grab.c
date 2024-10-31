#include <stdlib.h>
#include <vulkan/vulkan_core.h>

VkInstance *grab_vk_instance()
{
  void *data = malloc(sizeof(VkInstance));

  assert(data);

  return (VkInstance *)data;
}