/*
gst-launch-1.0  -v udpsrc port=5600 caps='application/x-rtp, media=(string)video, clock-rate=(int)90000, encoding-name=(string)H264' ! rtph264depay ! avdec_h264 ! videoconvert ! autovideosink fps-update-interval=1000 sync=false
*/

#include <gst/gst.h>


int main(int argc, char *argv[]) {
  GstElement *pipeline, *source, *capsfilter, *depay, *codec, *converter, *sink;
  GstBus *bus;
  GstMessage *msg;
  GstStateChangeReturn ret;
  GstCaps *caps = gst_caps_new_simple ("application/x-rtp",
      "media", G_TYPE_STRING, "video",
      "clock-rate", G_TYPE_INT, 90000,
      "encoding-name", G_TYPE_STRING, "H264",
      NULL);

  /* Initialize GStreamer */
  gst_init (&argc, &argv);

  /* Create the elements */
  source = gst_element_factory_make ("udpsrc", "source");
  capsfilter = gst_element_factory_make("capsfilter", "filter");
  depay = gst_element_factory_make ("rtph264depay", "depay");
  codec = gst_element_factory_make ("avdec_h264", "codec");
  converter = gst_element_factory_make ("videoconvert", "converter");
  sink = gst_element_factory_make ("autovideosink", "sink");

  /* Create the empty pipeline */
  pipeline = gst_pipeline_new ("test-pipeline");

  if (!pipeline || !source || !capsfilter || !sink || !depay || !codec || !converter) {
    g_printerr ("Not all elements could be created.\n");
    return -1;
  }


  /* Build the pipeline */
  gst_bin_add_many (GST_BIN (pipeline), source, capsfilter, depay, codec, converter, sink, NULL);
  //if( gst_element_link_filtered (source, depay, caps) != TRUE) {
      //g_printerr ("Caps could not be applied.\n");
  //}
  //gst_caps_unref (caps);
  if (gst_element_link_many (source, capsfilter, depay, codec, converter, sink, NULL) != TRUE) {
    g_printerr ("Elements could not be linked.\n");
    gst_object_unref (pipeline);
    return -1;
  }
  /* Modify the source's properties */
  g_object_set (source, "port", 5600, NULL);
  g_object_set (capsfilter, "caps", caps, NULL);
  gst_caps_unref(caps);
  /* Start playing */
  ret = gst_element_set_state (pipeline, GST_STATE_PLAYING);
  if (ret == GST_STATE_CHANGE_FAILURE) {
    g_printerr ("Unable to set the pipeline to the playing state.\n");
    gst_object_unref (pipeline);
    return -1;
  }

  /* Wait until error or EOS */
  bus = gst_element_get_bus (pipeline);
  msg = gst_bus_timed_pop_filtered (bus, GST_CLOCK_TIME_NONE, GST_MESSAGE_ERROR | GST_MESSAGE_EOS);

  /* Parse message */
  if (msg != NULL) {
    GError *err;
    gchar *debug_info;

    switch (GST_MESSAGE_TYPE (msg)) {
      case GST_MESSAGE_ERROR:
        gst_message_parse_error (msg, &err, &debug_info);
        g_printerr ("Error received from element %s: %s\n", GST_OBJECT_NAME (msg->src), err->message);
        g_printerr ("Debugging information: %s\n", debug_info ? debug_info : "none");
        g_clear_error (&err);
        g_free (debug_info);
        break;
      case GST_MESSAGE_EOS:
        g_print ("End-Of-Stream reached.\n");
        break;
      default:
        /* We should not reach here because we only asked for ERRORs and EOS */
        g_printerr ("Unexpected message received.\n");
        break;
    }
    gst_message_unref (msg);
  }

  /* Free resources */
  gst_object_unref (bus);
  gst_element_set_state (pipeline, GST_STATE_NULL);
  gst_object_unref (pipeline);
  return 0;
}
