import os
import subprocess
from models.muestras import Muestras
class Matlab:
    def __init__(self,muestra:Muestras):
        current_dir = muestra.ubicacion
        self.output_dir =os.path.join(current_dir, 'simulacion') 

    def crear_archivo_procesar_imagenes(self):
        """
        Crea y ejecuta el archivo MATLAB procesar_imagenes.m para segmentar objetos
        en imágenes dentro de varias subcarpetas.
        """
        # Script de MATLAB
        matlab_script = f"""
maxGap = 10;  % Máximo tamaño de brecha blanca que todavía consideramos parte del mismo objeto
minSize = 1000;  % Sólo guardar objetos mayores a 1000 píxeles
saveAll = true;

% Directorio base donde están las carpetas
baseDir = '{self.output_dir}';

% Listado de subcarpetas dentro de baseDir
subfolders = {{'Dogliotti2015', 'gons', 'gons740', 'mishra', 'moses3b', 'moses3b740', ...
            'ndci', 'ndvi', 'Nechad2009', 'Nechad2009ave', 'Nechad2010', ...
            'Nechad2010ave', 'Nechad2016', 'Novoa2017', 'oc22', 'oc33', ...
            'rgb', 'rhos', 'rhow', 'Rrs'}};

% Procesar cada subcarpeta
for k = 1:length(subfolders)
    % Ruta completa de la subcarpeta
    saveAll = true;
    inputDir = fullfile(baseDir, subfolders{{k}});
    
    % Obtener la lista de imágenes en la subcarpeta
    imageFiles = dir(fullfile(inputDir, '*.png'));
    images = {{imageFiles.name}};

    % Procesar cada imagen en la subcarpeta
    for i = 1:length(images)
        imageFile = fullfile(inputDir, images{{i}});
        separateObjectsWithMaxGapAndMinSize(imageFile, inputDir, maxGap, minSize, saveAll, images{{i}});
        saveAll = false;

        % Eliminar la imagen original después de procesarla
        delete(imageFile);
    end
end 

function separateObjectsWithMaxGapAndMinSize(imagePath, outputDir, maxGap, minSize, saveAll, originalName)
% Crear el directorio de salida si no existe
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Leer la imagen y convertirla a formato [0,1]
img = im2double(imread(imagePath));

% Si es escala de grises, convertirla a RGB
if size(img, 3) == 1
    img = repmat(img, [1 1 3]);
end

[height, width, ~] = size(img);

% Crear una máscara donde el foreground (no blanco) sea verdadero
nonWhiteMask = any(img < 1, 3);

% Operación morfológica de cierre
se = strel('square', maxGap + 1);
bwClosed = imclose(nonWhiteMask, se);

% Detectar componentes conectadas
cc = bwconncomp(bwClosed);

% Iterar sobre los objetos detectados
for j = 1:cc.NumObjects
    pixelList = cc.PixelIdxList{{j}};
    objectSize = numel(pixelList);

    % Verificar si el objeto supera el tamaño mínimo
    if objectSize >= minSize
        % Crear la máscara del objeto actual
        objectMask = false(height, width);
        objectMask(pixelList) = true;

        % Obtener las propiedades del objeto
        stats = regionprops(objectMask, 'BoundingBox');
        bbox = stats.BoundingBox;
        x = round(bbox(1)); y = round(bbox(2));
        w = round(bbox(3)); h = round(bbox(4));

        % Recortar el objeto
        objectImgCropped = img(y:y+h-1, x:x+w-1, :);

        % Acortar el nombre del archivo de salida para evitar rutas largas
        outputName = fullfile(outputDir, sprintf('%s_obj_%d.png', originalName(1:min(end, 20)), j));
        imwrite(objectImgCropped, outputName);
    end
end
end
        """

        # Guardar el script MATLAB
        matlab_script_path = os.path.join(self.output_dir, 'procesar_imagenes.m')
        with open(matlab_script_path, 'w') as matlab_file:
            matlab_file.write(matlab_script)
        print(f"Script MATLAB guardado en {matlab_script_path}")

        # Ejecutar el script en MATLAB
        try:
            result = subprocess.run(
                ['matlab', '-batch', f"run('{matlab_script_path}')"],
                capture_output=True,
                text=True
            )
            print("Salida estándar:", result.stdout)
            print("Salida de error:", result.stderr)
            print(f"Ejecutando script MATLAB completado.")
        except subprocess.CalledProcessError as e:
            print(f"Error al ejecutar MATLAB: {e}")

    def crear_archivo_transparencia(self):
        """
        Crea y ejecuta un script MATLAB para crear imágenes con transparencia eliminando fondo negro.
        """
        matlab_script = f"""
maxGap = 10;  % Máximo tamaño de brecha blanca
minSize = 1000;  % Tamaño mínimo de píxeles
outputFolder = '{self.output_dir}';
baseDir = '{self.output_dir}';  % Definir baseDir aquí

% Listado de subcarpetas dentro de baseDir
subfolders = {{'Dogliotti2015', 'gons', 'gons740', 'mishra', 'moses3b', 'moses3b740', ...
            'ndci', 'ndvi', 'Nechad2009', 'Nechad2009ave', 'Nechad2010', ...
            'Nechad2010ave', 'Nechad2016', 'Novoa2017', 'oc22', 'oc33', ...
            'rgb', 'rhos', 'rhow', 'Rrs'}};

% Procesar cada subcarpeta
for k = 1:length(subfolders)
    % Ruta completa de la subcarpeta
    saveAll = true;
    inputDir = fullfile(baseDir, subfolders{{k}});
    
    % Obtener la lista de imágenes en la subcarpeta
    imageFiles = dir(fullfile(inputDir, '*.png'));
    images = {{imageFiles.name}};

    % Procesar cada imagen en la subcarpeta
    for i = 1:length(images)
        % Leer la imagen actual
        imageFile = fullfile(inputDir, images{{i}});
        img = imread(imageFile);

        % Determinar el color de fondo según el píxel (1,1)
        backgroundColor = img(1, 1, :);

        % Separar el fondo del objeto
        isBackground = all(img == backgroundColor, 3);
        objectMask = ~isBackground;

        % Eliminar pequeños objetos no deseados (basados en tamaño)
        objectMask = bwareaopen(objectMask, minSize);

        % Rellenar huecos en los objetos hasta el tamaño maxGap
        objectMask = imclose(objectMask, strel('disk', maxGap));

        % Crear la imagen del objeto con transparencia
        objectImage = img;
        alphaChannel = uint8(objectMask) * 255;

        % Aplicar la máscara directamente para eliminar áreas de fondo
        for channel = 1:size(img, 3)
            objectImage(:,:,channel) = objectImage(:,:,channel) .* uint8(objectMask);
        end

        % Guardar la imagen resultante con transparencia
        [~, baseName, ext] = fileparts(images{{i}});
        areaOutputFile = fullfile(outputFolder, [baseName, '_area.png']);
        fondoOutputFile = fullfile(outputFolder, [baseName, '_fondo.png']);

        % Guardar la imagen con el área (sin fondo)
        imwrite(objectImage, areaOutputFile, 'Alpha', alphaChannel);

        % Crear una imagen con el fondo
        fondoImage = img .* uint8(isBackground);
        imwrite(fondoImage, fondoOutputFile);
    end
end

disp('Proceso completado.');
        """

        # Guardar el script MATLAB
        matlab_script_path = os.path.join(self.output_dir, 'transparencia.m')
        with open(matlab_script_path, 'w') as matlab_file:
            matlab_file.write(matlab_script)
        print(f"Script MATLAB guardado en {matlab_script_path}")

        # Ejecutar el script en MATLAB
        try:
            result = subprocess.run(
                ['matlab', '-batch', f"run('{matlab_script_path}')"],
                capture_output=True,
                text=True
            )
            print("Salida estándar:", result.stdout)
            print("Salida de error:", result.stderr)
            print(f"Ejecutando script MATLAB completado.")
        except subprocess.CalledProcessError as e:
            print(f"Error al ejecutar MATLAB: {e}")
