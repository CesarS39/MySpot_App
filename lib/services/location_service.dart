import 'package:geolocator/geolocator.dart';  // Paquete para obtener la ubicación del usuario
import 'package:geocoding/geocoding.dart';    // Paquete para convertir coordenadas geográficas a direcciones legibles
import 'package:shared_preferences/shared_preferences.dart';  // Paquete para almacenar datos localmente
/*
  Este servicio se encarga de gestionar la obtención, almacenamiento y acceso a la ubicación del usuario dentro de la app.

  **¿Cómo funciona?**
  1. **Obtener ubicación**:
     - La función principal `obtenerCiudad()` solicita los permisos necesarios para acceder a la ubicación del usuario.
     - Si los permisos son otorgados, la ubicación es obtenida utilizando la API de `Geolocator` para obtener la latitud y longitud del dispositivo.
     - Luego, las coordenadas obtenidas son convertidas en una dirección legible (como la ciudad) usando el paquete `geocoding`.

  2. **Persistencia de la ubicación**:
     - La ubicación obtenida (latitud y longitud) es guardada en la memoria local utilizando `SharedPreferences`. Esto permite que la ubicación se conserve incluso si la app se cierra y se vuelve a abrir.
     - Se utiliza la función privada `_guardarUbicacion()` para almacenar las coordenadas.

  3. **Recuperar ubicación guardada**:
     - Si se necesita acceder a la última ubicación obtenida, la función `obtenerUbicacionGuardada()` puede ser utilizada para recuperar las coordenadas (latitud y longitud) previamente almacenadas.

  **¿Cómo usarlo?**
  1. **Obtener la ciudad cuando se abre la app**:
     - Puedes llamar a `LocationService.obtenerCiudad()` en el `initState()` de cualquier pantalla (por ejemplo, `HomeScreen`) para obtener la ciudad basada en la ubicación actual del usuario tan pronto como se inicia la app.

  2. **Acceder a la ubicación guardada**:
     - Si en algún momento necesitas acceder a la última ubicación conocida (aunque no haya sido actualizada recientemente), puedes utilizar `LocationService.obtenerUbicacionGuardada()` para obtener las coordenadas latitud/longitud almacenadas.

  **Beneficios**:
  - Persistencia de la ubicación entre reinicios de la app.
  - Manejo fácil de permisos y servicios de ubicación.
  - Función de actualización de la ubicación siempre que se requiera.

  **Recomendaciones**:
  - Asegúrate de manejar correctamente los permisos de ubicación en Android e iOS, agregando las entradas correspondientes en los archivos de manifiesto (`AndroidManifest.xml` y `Info.plist`).
*/

class LocationService {
  // Función para obtener la ciudad basándose en las coordenadas del usuario
  static Future<String> obtenerCiudad() async {
    // Verificar si los servicios de ubicación están habilitados en el dispositivo
    bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      return 'Servicio de ubicación deshabilitado';  // Si los servicios de ubicación están deshabilitados, retornar un mensaje
    }

    // Comprobar el permiso de ubicación del usuario
    LocationPermission permiso = await Geolocator.checkPermission();

    // Si el permiso es denegado, solicitarlo
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();  // Solicitar permiso al usuario
      if (permiso == LocationPermission.denied) {
        return 'Permiso de ubicación denegado';  // Si el permiso sigue siendo denegado, retornar mensaje de error
      }
    }

    // Si el permiso es denegado para siempre (el usuario lo bloqueó permanentemente), mostrar un mensaje
    if (permiso == LocationPermission.deniedForever) {
      return 'Permiso de ubicación permanentemente denegado';
    }

    try {
      // Obtener la posición actual del usuario con la mejor precisión disponible
      Position posicion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      // Convertir las coordenadas (latitud, longitud) a una lista de lugares legibles (placemarks)
      List<Placemark> lugares = await placemarkFromCoordinates(posicion.latitude, posicion.longitude);

      Placemark lugar = lugares[0];  // Usamos el primer resultado de la lista de lugares

      // Guardamos las coordenadas obtenidas para futuras consultas
      _guardarUbicacion(posicion.latitude, posicion.longitude);

      // Retornamos la localidad (ciudad) o "Ciudad desconocida" si no se puede determinar
      return lugar.locality ?? 'Ciudad desconocida';
    } catch (e) {
      // En caso de error al obtener la ubicación, mostramos el error y actualizamos el estado
      return 'Error al obtener ubicación: $e';
    }
  }

  // Función privada para guardar la ubicación (latitud y longitud) en SharedPreferences
  static Future<void> _guardarUbicacion(double lat, double lon) async {
    // Accedemos a las preferencias compartidas (memoria local)
    final prefs = await SharedPreferences.getInstance();

    // Guardamos la latitud y longitud como valores dobles
    prefs.setDouble('lat', lat);
    prefs.setDouble('lon', lon);
  }

  // Función para obtener la ubicación guardada previamente (si existe) desde SharedPreferences
  static Future<Map<String, double?>> obtenerUbicacionGuardada() async {
    // Accedemos a las preferencias compartidas (memoria local)
    final prefs = await SharedPreferences.getInstance();

    // Obtenemos la latitud y longitud almacenadas (si están disponibles)
    double? lat = prefs.getDouble('lat');
    double? lon = prefs.getDouble('lon');

    // Retornamos las coordenadas guardadas como un mapa (lat, lon)
    return {'lat': lat, 'lon': lon};
  }
}