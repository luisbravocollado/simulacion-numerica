
maxGap = 10;  % Máximo tamaño de brecha blanca que todavía consideramos parte del mismo objeto
minSize = 10000;  % Sólo guardar objetos mayores a 10000 píxeles
saveAll = true;

% Directorio base donde están las carpetas
baseDir = 'C:\\Users\\Luisbra\\Desktop\\funcional\\simulacion';

% Listado de subcarpetas dentro de baseDir
subfolders = {'Dogliotti2015', 'gons', 'gons740', 'mishra', 'moses3b', 'moses3b740', ...
            'ndci', 'ndvi', 'Nechad2009', 'Nechad2009ave', 'Nechad2010', ...
            'Nechad2010ave', 'Nechad2016', 'Novoa2017', 'oc22', 'oc33', ...
            'rgb', 'rhos', 'rhow', 'Rrs'};

% Procesar cada subcarpeta
for k = 1:length(subfolders)
    % Ruta completa de la subcarpeta
    saveAll = true;
    inputDir = fullfile(baseDir, subfolders{k});
    
    % Obtener la lista de imágenes en la subcarpeta
    imageFiles = dir(fullfile(inputDir, '*.png'));
    images = {imageFiles.name};

    % Procesar cada imagen en la subcarpeta
    for i = 1:length(images)
        imageFile = fullfile(inputDir, images{i});
        separateObjectsWithMaxGapAndMinSize(imageFile, inputDir, maxGap, minSize, saveAll, images{i});
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
    pixelList = cc.PixelIdxList{j};
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
        