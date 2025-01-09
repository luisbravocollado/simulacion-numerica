
maxGap = 10;  % Máximo tamaño de brecha blanca
minSize = 100;  % Tamaño mínimo de píxeles
outputFolder = 'C:\\Users\\Luisbra\\Desktop\\funcional\\simulacion';
baseDir = 'C:\\Users\\Luisbra\\Desktop\\funcional\\simulacion';  % Definir baseDir aquí

% Listado de subcarpetas dentro de baseDir
subfolders = {'Dogliotti2015', 'gons', 'gons740', 'mishra', 'moses3b', 'moses3b740', ...
            'ndci', 'ndvi', 'Nechad2009', 'Nechad2009ave', 'Nechad2010', ...
            'Nechad2010ave', 'Nechad2016', 'Novoa2017', 'oc22', 'oc33', ...
            'rgb', 'Rrs'};

for k = 1:length(subfolders)
    % Ruta completa de la subcarpeta
    saveAll = true;
    inputDir = fullfile(baseDir, subfolders{k});
    
    % Obtener la lista de imágenes en la subcarpeta
    imageFiles = dir(fullfile(inputDir, '*.png'));
    images = {imageFiles.name};

    % Procesar cada imagen en la subcarpeta
    for i = 1:length(images)
        % Leer la imagen actual
        imageFile = fullfile(inputDir, images{i});
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
        objectImage = img .* uint8(objectMask);
        alphaChannel = uint8(objectMask) * 255;

        % Crear la imagen del fondo
        fondoImage = img;  % Copiar la imagen original
        fondoImage(repmat(~isBackground, [1, 1, 3])) = 0;  % Establecer los píxeles de los objetos a negro (o transparentes si usas Alpha)

        % Guardar las imágenes resultantes con el mismo nombre en la carpeta de entrada
        [~, baseName, ext] = fileparts(images{i});
        areaOutputFile = fullfile(inputDir, [baseName, '_area.png']);
        fondoOutputFile = fullfile(inputDir, [baseName, '_fondo.png']);

        % Guardar la imagen con el área (sin fondo)
        imwrite(objectImage, areaOutputFile, 'Alpha', alphaChannel);

        % Guardar la imagen con el fondo
        imwrite(fondoImage, fondoOutputFile);
    end
end

disp('Proceso completado.');

        