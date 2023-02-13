﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Функция определяет необходимость выполнения замеров.
//
// Возвращаемое значение:
//  Булево - Истина выполнять, Ложь не выполнять.
//
Функция ВыполнятьЗамерыПроизводительности() Экспорт
	
	УстановитьПривилегированныйРежим(Истина);
	Возврат Константы.ВыполнятьЗамерыПроизводительности.Получить();
	
КонецФункции

#КонецОбласти
