﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

Функция УникальноеИмяФайла(Знач ИмяФайла) Экспорт
	
	Файл = Новый Файл(ИмяФайла);
	ИмяБезРасширения = Файл.ИмяБезРасширения;
	Расширение = Файл.Расширение;
	ИмяКаталога = Файл.Путь;
	
	Счетчик = 1;
	Пока Файл.Существует() Цикл
		Счетчик = Счетчик + 1;
		Файл = Новый Файл(ИмяКаталога + ИмяБезРасширения + " (" + Счетчик + ")" + Расширение);
	КонецЦикла;
	
	Возврат Файл.ПолноеИмя;

КонецФункции

#КонецОбласти