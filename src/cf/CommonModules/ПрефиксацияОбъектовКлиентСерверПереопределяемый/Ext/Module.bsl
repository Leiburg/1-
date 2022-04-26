﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2022, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Обработчик события "При получении номера на печать".
// Событие возникает перед стандартной обработкой получения номера.
// В обработчике можно переопределить стандартное поведение системы при формировании номера на печать.
//
// Параметры:
//  НомерОбъекта                     - Строка - номер или код объекта, который обрабатывается.
//  СтандартнаяОбработка             - Булево - флаг стандартной обработки; если установить значение флага в Ложь,
//                                              то стандартная обработка формирования номера на печать выполняться
//                                              не будет.
//  УдалитьПрефиксИнформационнойБазы - Булево - признак удаления префикса информационной базы;
//                                              по умолчанию равен Ложь.
//  УдалитьПользовательскийПрефикс   - Булево - признак удаления пользовательского префикса;
//                                              по умолчанию равен Ложь.
//
// Пример:
//
//   НомерОбъекта = ПрефиксацияОбъектовКлиентСервер.УдалитьПользовательскиеПрефиксыИзНомераОбъекта(НомерОбъекта);
//   СтандартнаяОбработка = Ложь;
//
Процедура ПриПолученииНомераНаПечать(НомерОбъекта, СтандартнаяОбработка,
	УдалитьПрефиксИнформационнойБазы, УдалитьПользовательскийПрефикс) Экспорт
	
КонецПроцедуры

#КонецОбласти
