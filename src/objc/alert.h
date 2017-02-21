typedef void (*alert_callback_t)();
typedef void (*alert_input_callback_t)(const char *response);
void alert_display(const char *title, const char *msg, const char *cancel, const char *ok, alert_callback_t callback);
void alert_input(const char *title, const char *msg, const char *cancel, const char *ok, alert_input_callback_t callback);
