﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2020, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// ТехнологияСервиса.ВыгрузкаЗагрузкаДанных

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриРегистрацииОбработчиковВыгрузкиДанных.
Процедура ПередВыгрузкойОбъекта(Контейнер, МенеджерВыгрузкиОбъекта, Сериализатор, Объект, Артефакты, Отказ) Экспорт
	
	УправлениеДоступомСлужебный.ПередВыгрузкойНабораЗаписей(Контейнер, МенеджерВыгрузкиОбъекта, Сериализатор, Объект, Артефакты, Отказ);
	
КонецПроцедуры

// Конец ТехнологияСервиса.ВыгрузкаЗагрузкаДанных

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Процедура обновляет данные регистра при изменении
// - разрешенных значений групп доступа,
// - разрешенных значений профилей групп доступа,
// - использования видов доступа.
//
// Параметры:
//  ГруппыДоступа - СправочникСсылка.ГруппыДоступа.
//                - массив значений указанных выше типов.
//                - Неопределено - без отбора.
//
//  ЕстьИзменения - Булево - (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьДанныеРегистра(ГруппыДоступа = Неопределено, ЕстьИзменения = Неопределено) Экспорт
	
	Блокировка = Новый БлокировкаДанных;
	Блокировка.Добавить("РегистрСведений.ЗначенияГруппДоступа");
	Блокировка.Добавить("РегистрСведений.ЗначенияГруппДоступаПоУмолчанию");
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		
		ИспользуемыеВидыДоступа = Новый ТаблицаЗначений;
		ИспользуемыеВидыДоступа.Колонки.Добавить("ВидДоступа", Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип);
		ИспользуемыеВидыДоступа.Колонки.Добавить("ВидДоступаПользователи",        Новый ОписаниеТипов("Булево"));
		ИспользуемыеВидыДоступа.Колонки.Добавить("ВидДоступаВнешниеПользователи", Новый ОписаниеТипов("Булево"));
		
		СвойстваВидовДоступа = УправлениеДоступомСлужебныйПовтИсп.СвойстваВидовДоступа();
		
		Для Каждого СвойстваВидаДоступа Из СвойстваВидовДоступа.Массив Цикл
			Если Не УправлениеДоступомСлужебный.ВидДоступаИспользуется(СвойстваВидаДоступа.Ссылка)
			   И Не СвойстваВидаДоступа.Имя = "ДополнительныеОтчетыИОбработки" Тогда
				Продолжить;
			КонецЕсли;
			НоваяСтрока = ИспользуемыеВидыДоступа.Добавить();
			НоваяСтрока.ВидДоступа = СвойстваВидаДоступа.Ссылка;
			НоваяСтрока.ВидДоступаПользователи        = (СвойстваВидаДоступа.Имя = "Пользователи");
			НоваяСтрока.ВидДоступаВнешниеПользователи = (СвойстваВидаДоступа.Имя = "ВнешниеПользователи");
		КонецЦикла;
		
		ОбновитьРазрешенныеЗначения(ИспользуемыеВидыДоступа, ГруппыДоступа, ЕстьИзменения);
		
		ОбновитьРазрешенныеЗначенияПоУмолчанию(ИспользуемыеВидыДоступа, ГруппыДоступа, ЕстьИзменения);
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Вспомогательные процедуры и функции.

Процедура ОбновитьРазрешенныеЗначения(ИспользуемыеВидыДоступа, ГруппыДоступа = Неопределено, ЕстьИзменения = Неопределено)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИспользуемыеВидыДоступа", ИспользуемыеВидыДоступа);
	
	Запрос.УстановитьПараметр("ТипыГруппИЗначенийВидовДоступа",
		УправлениеДоступомСлужебныйПовтИсп.ТипыГруппИЗначенийВидовДоступа());
		
	Запрос.УстановитьПараметр("ВыбранныеЗначенияДоступа", ВыбранныеЗначенияДоступа(ГруппыДоступа));
	
	ТекстЗапросовВременныхТаблиц =
	"ВЫБРАТЬ
	|	ВыбранныеЗначенияДоступа.Значение КАК Значение,
	|	ВыбранныеЗначенияДоступа.ЗначениеВИерархии КАК ЗначениеВИерархии
	|ПОМЕСТИТЬ ВыбранныеЗначенияДоступа
	|ИЗ
	|	&ВыбранныеЗначенияДоступа КАК ВыбранныеЗначенияДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИспользуемыеВидыДоступа.ВидДоступа КАК ВидДоступа,
	|	ИспользуемыеВидыДоступа.ВидДоступаПользователи КАК ВидДоступаПользователи,
	|	ИспользуемыеВидыДоступа.ВидДоступаВнешниеПользователи КАК ВидДоступаВнешниеПользователи
	|ПОМЕСТИТЬ ИспользуемыеВидыДоступа
	|ИЗ
	|	&ИспользуемыеВидыДоступа КАК ИспользуемыеВидыДоступа
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ИспользуемыеВидыДоступа.ВидДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Назначение.Ссылка КАК Профиль,
	|	МИНИМУМ(ТИПЗНАЧЕНИЯ(Назначение.ТипПользователей) = ТИП(Справочник.Пользователи)) КАК ТолькоДляПользователей,
	|	МИНИМУМ(ТИПЗНАЧЕНИЯ(Назначение.ТипПользователей) <> ТИП(Справочник.Пользователи)
	|			И Назначение.ТипПользователей <> НЕОПРЕДЕЛЕНО) КАК ТолькоДляВнешнихПользователей
	|ПОМЕСТИТЬ НазначениеПрофилей
	|ИЗ
	|	Справочник.ПрофилиГруппДоступа.Назначение КАК Назначение
	|
	|СГРУППИРОВАТЬ ПО
	|	Назначение.Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НазначениеПрофилей.Профиль КАК Профиль,
	|	ИспользуемыеВидыДоступа.ВидДоступа КАК ВидДоступа
	|ПОМЕСТИТЬ ВидыДоступаПрофилейВсеЗапрещены
	|ИЗ
	|	ИспользуемыеВидыДоступа КАК ИспользуемыеВидыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ НазначениеПрофилей КАК НазначениеПрофилей
	|		ПО (ИспользуемыеВидыДоступа.ВидДоступаПользователи
	|					И НЕ НазначениеПрофилей.ТолькоДляПользователей
	|				ИЛИ ИспользуемыеВидыДоступа.ВидДоступаВнешниеПользователи
	|					И НЕ НазначениеПрофилей.ТолькоДляВнешнихПользователей)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	НазначениеПрофилей.Профиль,
	|	ИспользуемыеВидыДоступа.ВидДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТипыГруппИЗначенийВидовДоступа.ВидДоступа КАК ВидДоступа,
	|	ТипыГруппИЗначенийВидовДоступа.ТипГруппИЗначений КАК ТипГруппИЗначений
	|ПОМЕСТИТЬ ТипыГруппИЗначенийВидовДоступа
	|ИЗ
	|	&ТипыГруппИЗначенийВидовДоступа КАК ТипыГруппИЗначенийВидовДоступа
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ТипыГруппИЗначенийВидовДоступа.ТипГруппИЗначений,
	|	ТипыГруппИЗначенийВидовДоступа.ВидДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ГруппыДоступа.Ссылка КАК Ссылка,
	|	ГруппыДоступа.Профиль КАК Профиль
	|ПОМЕСТИТЬ ГруппыДоступа
	|ИЗ
	|	Справочник.ГруппыДоступа КАК ГруппыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа КАК ПрофилиГруппДоступа
	|		ПО ГруппыДоступа.Профиль = ПрофилиГруппДоступа.Ссылка
	|			И (ГруппыДоступа.Профиль <> ЗНАЧЕНИЕ(Справочник.ПрофилиГруппДоступа.Администратор))
	|			И (НЕ ГруппыДоступа.ПометкаУдаления)
	|			И (НЕ ПрофилиГруппДоступа.ПометкаУдаления)
	|			И (&УсловиеОтбораГруппДоступа1)
	|			И (ИСТИНА В
	|				(ВЫБРАТЬ ПЕРВЫЕ 1
	|					ИСТИНА КАК ЗначениеИстина
	|				ИЗ
	|					Справочник.ГруппыДоступа.Пользователи КАК УчастникиГруппДоступа
	|				ГДЕ
	|					УчастникиГруппДоступа.Ссылка = ГруппыДоступа.Ссылка))
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ГруппыДоступа.Профиль
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ГруппыДоступа.Профиль КАК Профиль,
	|	ГруппыДоступа.Ссылка КАК ГруппаДоступа,
	|	ЗначенияДоступаПрофиля.ВидДоступа КАК ВидДоступа,
	|	ЗначенияДоступаПрофиля.ЗначениеДоступа КАК ЗначениеДоступа,
	|	ЗначенияДоступаПрофиля.ВключаяНижестоящие КАК ВключаяНижестоящие,
	|	ВЫБОР
	|		КОГДА ВидыДоступаПрофиля.ВсеРазрешены
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ КАК ЗначениеРазрешено
	|ПОМЕСТИТЬ НастройкиЗначений
	|ИЗ
	|	ГруппыДоступа КАК ГруппыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа.ВидыДоступа КАК ВидыДоступаПрофиля
	|		ПО ГруппыДоступа.Профиль = ВидыДоступаПрофиля.Ссылка
	|			И (ВидыДоступаПрофиля.Предустановленный)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа.ЗначенияДоступа КАК ЗначенияДоступаПрофиля
	|		ПО (ЗначенияДоступаПрофиля.Ссылка = ВидыДоступаПрофиля.Ссылка)
	|			И (ЗначенияДоступаПрофиля.ВидДоступа = ВидыДоступаПрофиля.ВидДоступа)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ГруппыДоступа.Профиль,
	|	ГруппыДоступа.Ссылка,
	|	ЗначенияДоступа.ВидДоступа,
	|	ЗначенияДоступа.ЗначениеДоступа,
	|	ЗначенияДоступа.ВключаяНижестоящие,
	|	ВЫБОР
	|		КОГДА ВидыДоступа.ВсеРазрешены
	|			ТОГДА ЛОЖЬ
	|		ИНАЧЕ ИСТИНА
	|	КОНЕЦ
	|ИЗ
	|	ГруппыДоступа КАК ГруппыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ГруппыДоступа.ВидыДоступа КАК ВидыДоступа
	|		ПО (ВидыДоступа.Ссылка = ГруппыДоступа.Ссылка)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа.ВидыДоступа КАК ЗаданныеВидыДоступа
	|		ПО (ЗаданныеВидыДоступа.Ссылка = ГруппыДоступа.Профиль)
	|			И (ЗаданныеВидыДоступа.ВидДоступа = ВидыДоступа.ВидДоступа)
	|			И (НЕ ЗаданныеВидыДоступа.Предустановленный)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ГруппыДоступа.ЗначенияДоступа КАК ЗначенияДоступа
	|		ПО (ЗначенияДоступа.Ссылка = ГруппыДоступа.Ссылка)
	|			И (ЗначенияДоступа.ВидДоступа = ВидыДоступа.ВидДоступа)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НастройкиЗначений.ГруппаДоступа КАК ГруппаДоступа,
	|	ВЫБОР
	|		КОГДА НастройкиЗначений.ВключаяНижестоящие
	|			ТОГДА ВыбранныеЗначенияДоступа.ЗначениеВИерархии
	|		ИНАЧЕ НастройкиЗначений.ЗначениеДоступа
	|	КОНЕЦ КАК ЗначениеДоступа,
	|	МАКСИМУМ(НастройкиЗначений.ЗначениеРазрешено) КАК ЗначениеРазрешено
	|ПОМЕСТИТЬ НовыеДанные
	|ИЗ
	|	НастройкиЗначений КАК НастройкиЗначений
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ТипыГруппИЗначенийВидовДоступа КАК ТипыГруппИЗначенийВидовДоступа
	|		ПО НастройкиЗначений.ВидДоступа = ТипыГруппИЗначенийВидовДоступа.ВидДоступа
	|			И (ТИПЗНАЧЕНИЯ(НастройкиЗначений.ЗначениеДоступа) = ТИПЗНАЧЕНИЯ(ТипыГруппИЗначенийВидовДоступа.ТипГруппИЗначений))
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ИспользуемыеВидыДоступа КАК ИспользуемыеВидыДоступа
	|		ПО НастройкиЗначений.ВидДоступа = ИспользуемыеВидыДоступа.ВидДоступа
	|			И (НЕ (НастройкиЗначений.Профиль, НастройкиЗначений.ВидДоступа) В
	|					(ВЫБРАТЬ
	|						ВидыДоступаПрофилейВсеЗапрещены.Профиль,
	|						ВидыДоступаПрофилейВсеЗапрещены.ВидДоступа
	|					ИЗ
	|						ВидыДоступаПрофилейВсеЗапрещены КАК ВидыДоступаПрофилейВсеЗапрещены))
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВыбранныеЗначенияДоступа КАК ВыбранныеЗначенияДоступа
	|		ПО НастройкиЗначений.ЗначениеДоступа = ВыбранныеЗначенияДоступа.Значение
	|
	|СГРУППИРОВАТЬ ПО
	|	НастройкиЗначений.ГруппаДоступа,
	|	ВЫБОР
	|		КОГДА НастройкиЗначений.ВключаяНижестоящие
	|			ТОГДА ВыбранныеЗначенияДоступа.ЗначениеВИерархии
	|		ИНАЧЕ НастройкиЗначений.ЗначениеДоступа
	|	КОНЕЦ
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	НастройкиЗначений.ГруппаДоступа,
	|	ЗначениеДоступа,
	|	ЗначениеРазрешено
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ НастройкиЗначений";
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	НовыеДанные.ГруппаДоступа,
	|	НовыеДанные.ЗначениеДоступа,
	|	НовыеДанные.ЗначениеРазрешено,
	|	&ПодстановкаПоляВидИзмененияСтроки
	|ИЗ
	|	НовыеДанные КАК НовыеДанные";
	
	// Подготовка выбираемых полей с необязательным отбором.
	Поля = Новый Массив; 
	Поля.Добавить(Новый Структура("ГруппаДоступа", "&УсловиеОтбораГруппДоступа2"));
	Поля.Добавить(Новый Структура("ЗначениеДоступа"));
	Поля.Добавить(Новый Структура("ЗначениеРазрешено"));
	
	Запрос.Текст = УправлениеДоступомСлужебный.ТекстЗапросаВыбораИзменений(
		ТекстЗапроса, Поля, "РегистрСведений.ЗначенияГруппДоступа", ТекстЗапросовВременныхТаблиц);
	
	УправлениеДоступомСлужебный.УстановитьУсловиеОтбораВЗапросе(Запрос, ГруппыДоступа, "ГруппыДоступа",
		"&УсловиеОтбораГруппДоступа1:ГруппыДоступа.Ссылка
		|&УсловиеОтбораГруппДоступа2:СтарыеДанные.ГруппаДоступа");
	
	Данные = Новый Структура;
	Данные.Вставить("МенеджерРегистра",      РегистрыСведений.ЗначенияГруппДоступа);
	Данные.Вставить("ИзмененияСоставаСтрок", Запрос.Выполнить().Выгрузить());
	Данные.Вставить("ИзмеренияОтбора",       "ГруппаДоступа");
	
	НачатьТранзакцию();
	Попытка
		ЕстьТекущиеИзменения = Ложь;
		УправлениеДоступомСлужебный.ОбновитьРегистрСведений(Данные, ЕстьТекущиеИзменения);
		Если ЕстьТекущиеИзменения Тогда
			ЕстьИзменения = Истина;
		КонецЕсли;
		
		Если ЕстьТекущиеИзменения
		   И УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
			
			// Планирование обновления доступа.
			ПустыеСсылкиПоТипам = УправлениеДоступомСлужебныйПовтИсп.ПустыеСсылкиТиповЗначенийДоступаПоТипамГруппИЗначений();
			СоставИзменений = Новый ТаблицаЗначений;
			СоставИзменений.Колонки.Добавить("ГруппаДоступа", Новый ОписаниеТипов("СправочникСсылка.ГруппыДоступа"));
			СоставИзменений.Колонки.Добавить("ТипЗначенийДоступа", Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип);
			
			Для Каждого Строка Из Данные.ИзмененияСоставаСтрок Цикл
				ПустыеСсылки = ПустыеСсылкиПоТипам.Получить(ТипЗнч(Строка.ЗначениеДоступа));
				Для Каждого ПустаяСсылка Из ПустыеСсылки Цикл
					НоваяСтрока = СоставИзменений.Добавить();
					НоваяСтрока.ГруппаДоступа = Строка.ГруппаДоступа;
					НоваяСтрока.ТипЗначенийДоступа = ПустаяСсылка;
				КонецЦикла;
			КонецЦикла;
			СоставИзменений.Свернуть("ГруппаДоступа, ТипЗначенийДоступа");
			
			УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступаПриИзмененииРазрешенныхЗначений(СоставИзменений);
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Процедура ОбновитьРазрешенныеЗначенияПоУмолчанию(ИспользуемыеВидыДоступа, ГруппыДоступа = Неопределено, ЕстьИзменения = Неопределено)
	
	УстановитьПривилегированныйРежим(Истина);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("ИспользуемыеВидыДоступа", ИспользуемыеВидыДоступа);
	
	Запрос.УстановитьПараметр("ТипыГруппИЗначенийВидовДоступа",
		УправлениеДоступомСлужебныйПовтИсп.ТипыГруппИЗначенийВидовДоступа());
	
	ТекстЗапросовВременныхТаблиц =
	"ВЫБРАТЬ
	|	ИспользуемыеВидыДоступа.ВидДоступа КАК ВидДоступа,
	|	ИспользуемыеВидыДоступа.ВидДоступаПользователи КАК ВидДоступаПользователи,
	|	ИспользуемыеВидыДоступа.ВидДоступаВнешниеПользователи КАК ВидДоступаВнешниеПользователи
	|ПОМЕСТИТЬ ИспользуемыеВидыДоступа
	|ИЗ
	|	&ИспользуемыеВидыДоступа КАК ИспользуемыеВидыДоступа
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ИспользуемыеВидыДоступа.ВидДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Назначение.Ссылка КАК Профиль,
	|	МИНИМУМ(ТИПЗНАЧЕНИЯ(Назначение.ТипПользователей) = ТИП(Справочник.Пользователи)) КАК ТолькоДляПользователей,
	|	МИНИМУМ(ТИПЗНАЧЕНИЯ(Назначение.ТипПользователей) <> ТИП(Справочник.Пользователи)
	|			И Назначение.ТипПользователей <> НЕОПРЕДЕЛЕНО) КАК ТолькоДляВнешнихПользователей
	|ПОМЕСТИТЬ НазначениеПрофилей
	|ИЗ
	|	Справочник.ПрофилиГруппДоступа.Назначение КАК Назначение
	|
	|СГРУППИРОВАТЬ ПО
	|	Назначение.Ссылка
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	НазначениеПрофилей.Профиль КАК Профиль,
	|	ИспользуемыеВидыДоступа.ВидДоступа КАК ВидДоступа,
	|	ЛОЖЬ КАК ЗначениеЛожь
	|ПОМЕСТИТЬ ВидыДоступаПрофилейВсеЗапрещены
	|ИЗ
	|	ИспользуемыеВидыДоступа КАК ИспользуемыеВидыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ НазначениеПрофилей КАК НазначениеПрофилей
	|		ПО (ИспользуемыеВидыДоступа.ВидДоступаПользователи
	|					И НЕ НазначениеПрофилей.ТолькоДляПользователей
	|				ИЛИ ИспользуемыеВидыДоступа.ВидДоступаВнешниеПользователи
	|					И НЕ НазначениеПрофилей.ТолькоДляВнешнихПользователей)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	НазначениеПрофилей.Профиль,
	|	ИспользуемыеВидыДоступа.ВидДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТипыГруппИЗначенийВидовДоступа.ВидДоступа КАК ВидДоступа,
	|	ТипыГруппИЗначенийВидовДоступа.ТипГруппИЗначений КАК ТипГруппИЗначений
	|ПОМЕСТИТЬ ТипыГруппИЗначенийВидовДоступа
	|ИЗ
	|	&ТипыГруппИЗначенийВидовДоступа КАК ТипыГруппИЗначенийВидовДоступа
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ТипыГруппИЗначенийВидовДоступа.ТипГруппИЗначений,
	|	ТипыГруппИЗначенийВидовДоступа.ВидДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ГруппыДоступа.Ссылка КАК Ссылка,
	|	ГруппыДоступа.Профиль КАК Профиль
	|ПОМЕСТИТЬ ГруппыДоступа
	|ИЗ
	|	Справочник.ГруппыДоступа КАК ГруппыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа КАК ПрофилиГруппДоступа
	|		ПО ГруппыДоступа.Профиль = ПрофилиГруппДоступа.Ссылка
	|			И (ГруппыДоступа.Профиль <> ЗНАЧЕНИЕ(Справочник.ПрофилиГруппДоступа.Администратор))
	|			И (НЕ ГруппыДоступа.ПометкаУдаления)
	|			И (НЕ ПрофилиГруппДоступа.ПометкаУдаления)
	|			И (&УсловиеОтбораГруппДоступа1)
	|			И (ИСТИНА В
	|				(ВЫБРАТЬ ПЕРВЫЕ 1
	|					ИСТИНА КАК ЗначениеИстина
	|				ИЗ
	|					Справочник.ГруппыДоступа.Пользователи КАК УчастникиГруппДоступа
	|				ГДЕ
	|					УчастникиГруппДоступа.Ссылка = ГруппыДоступа.Ссылка))
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ГруппыДоступа.Профиль
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ГруппыДоступа.Ссылка КАК ГруппаДоступа,
	|	ВидыДоступаПрофиля.ВидДоступа КАК ВидДоступа,
	|	ВидыДоступаПрофиля.ВсеРазрешены КАК ВсеРазрешены
	|ПОМЕСТИТЬ НастройкиВидовДоступа
	|ИЗ
	|	ГруппыДоступа КАК ГруппыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа.ВидыДоступа КАК ВидыДоступаПрофиля
	|		ПО ГруппыДоступа.Профиль = ВидыДоступаПрофиля.Ссылка
	|			И (ВидыДоступаПрофиля.Предустановленный)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ИспользуемыеВидыДоступа КАК ИспользуемыеВидыДоступа
	|		ПО (ВидыДоступаПрофиля.ВидДоступа = ИспользуемыеВидыДоступа.ВидДоступа)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВидыДоступа.Ссылка,
	|	ВидыДоступа.ВидДоступа,
	|	ВидыДоступа.ВсеРазрешены
	|ИЗ
	|	ГруппыДоступа КАК ГруппыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ГруппыДоступа.ВидыДоступа КАК ВидыДоступа
	|		ПО (ВидыДоступа.Ссылка = ГруппыДоступа.Ссылка)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа.ВидыДоступа КАК ЗаданныеВидыДоступа
	|		ПО (ЗаданныеВидыДоступа.Ссылка = ГруппыДоступа.Профиль)
	|			И (ЗаданныеВидыДоступа.ВидДоступа = ВидыДоступа.ВидДоступа)
	|			И (НЕ ЗаданныеВидыДоступа.Предустановленный)
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ИспользуемыеВидыДоступа КАК ИспользуемыеВидыДоступа
	|		ПО (ВидыДоступа.ВидДоступа = ИспользуемыеВидыДоступа.ВидДоступа)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	НастройкиЗначений.ГруппаДоступа КАК ГруппаДоступа,
	|	ТипыГруппИЗначенийВидовДоступа.ВидДоступа КАК ВидДоступа,
	|	ИСТИНА КАК СНастройкой
	|ПОМЕСТИТЬ НаличиеНастроекЗначений
	|ИЗ
	|	ТипыГруппИЗначенийВидовДоступа КАК ТипыГруппИЗначенийВидовДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЗначенияГруппДоступа КАК НастройкиЗначений
	|		ПО (ТИПЗНАЧЕНИЯ(ТипыГруппИЗначенийВидовДоступа.ТипГруппИЗначений) = ТИПЗНАЧЕНИЯ(НастройкиЗначений.ЗначениеДоступа))
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ИспользуемыеВидыДоступа КАК ИспользуемыеВидыДоступа
	|		ПО ТипыГруппИЗначенийВидовДоступа.ВидДоступа = ИспользуемыеВидыДоступа.ВидДоступа
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ГруппыДоступа.Ссылка КАК ГруппаДоступа,
	|	ТипыГруппИЗначенийВидовДоступа.ТипГруппИЗначений КАК ТипЗначенийДоступа,
	|	МАКСИМУМ(ЕСТЬNULL(ВидыДоступаПрофилейВсеЗапрещены.ЗначениеЛожь, ЕСТЬNULL(НастройкиВидовДоступа.ВсеРазрешены, ИСТИНА))) КАК ВсеРазрешены,
	|	МАКСИМУМ(ЕСТЬNULL(ВидыДоступаПрофилейВсеЗапрещены.ЗначениеЛожь, НастройкиВидовДоступа.ВсеРазрешены ЕСТЬ NULL)) КАК ВидДоступаНеИспользуется,
	|	МАКСИМУМ(ЕСТЬNULL(НаличиеНастроекЗначений.СНастройкой, ЛОЖЬ)) КАК СНастройкой
	|ПОМЕСТИТЬ ЗаготовкаДляНовыхДанных
	|ИЗ
	|	ГруппыДоступа КАК ГруппыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ТипыГруппИЗначенийВидовДоступа КАК ТипыГруппИЗначенийВидовДоступа
	|		ПО (ИСТИНА)
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВидыДоступаПрофилейВсеЗапрещены КАК ВидыДоступаПрофилейВсеЗапрещены
	|		ПО (ВидыДоступаПрофилейВсеЗапрещены.Профиль = ГруппыДоступа.Профиль)
	|			И (ВидыДоступаПрофилейВсеЗапрещены.ВидДоступа = ТипыГруппИЗначенийВидовДоступа.ВидДоступа)
	|		ЛЕВОЕ СОЕДИНЕНИЕ НастройкиВидовДоступа КАК НастройкиВидовДоступа
	|		ПО (НастройкиВидовДоступа.ГруппаДоступа = ГруппыДоступа.Ссылка)
	|			И (НастройкиВидовДоступа.ВидДоступа = ТипыГруппИЗначенийВидовДоступа.ВидДоступа)
	|		ЛЕВОЕ СОЕДИНЕНИЕ НаличиеНастроекЗначений КАК НаличиеНастроекЗначений
	|		ПО (НаличиеНастроекЗначений.ГруппаДоступа = НастройкиВидовДоступа.ГруппаДоступа)
	|			И (НаличиеНастроекЗначений.ВидДоступа = НастройкиВидовДоступа.ВидДоступа)
	|
	|СГРУППИРОВАТЬ ПО
	|	ГруппыДоступа.Ссылка,
	|	ТипыГруппИЗначенийВидовДоступа.ТипГруппИЗначений
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ГруппыДоступа.Ссылка,
	|	ТипыГруппИЗначенийВидовДоступа.ТипГруппИЗначений
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗаготовкаДляНовыхДанных.ГруппаДоступа КАК ГруппаДоступа,
	|	ЗаготовкаДляНовыхДанных.ТипЗначенийДоступа КАК ТипЗначенийДоступа,
	|	ЗаготовкаДляНовыхДанных.ВсеРазрешены КАК ВсеРазрешены,
	|	ВЫБОР
	|		КОГДА ЗаготовкаДляНовыхДанных.ВсеРазрешены = ИСТИНА
	|				И ЗаготовкаДляНовыхДанных.СНастройкой = ЛОЖЬ
	|			ТОГДА ИСТИНА
	|		ИНАЧЕ ЛОЖЬ
	|	КОНЕЦ КАК ВсеРазрешеныБезИсключений,
	|	ЗаготовкаДляНовыхДанных.ВидДоступаНеИспользуется КАК БезНастройки
	|ПОМЕСТИТЬ НовыеДанные
	|ИЗ
	|	ЗаготовкаДляНовыхДанных КАК ЗаготовкаДляНовыхДанных
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	ЗаготовкаДляНовыхДанных.ГруппаДоступа,
	|	ЗаготовкаДляНовыхДанных.ТипЗначенийДоступа,
	|	ЗаготовкаДляНовыхДанных.ВсеРазрешены,
	|	ВсеРазрешеныБезИсключений,
	|	БезНастройки
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|УНИЧТОЖИТЬ НастройкиВидовДоступа";
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	НовыеДанные.ГруппаДоступа,
	|	НовыеДанные.ТипЗначенийДоступа,
	|	НовыеДанные.ВсеРазрешены,
	|	НовыеДанные.ВсеРазрешеныБезИсключений,
	|	НовыеДанные.БезНастройки,
	|	&ПодстановкаПоляВидИзмененияСтроки
	|ИЗ
	|	НовыеДанные КАК НовыеДанные";
	
	// Подготовка выбираемых полей с необязательным отбором.
	Поля = Новый Массив; 
	Поля.Добавить(Новый Структура("ГруппаДоступа", "&УсловиеОтбораГруппДоступа2"));
	Поля.Добавить(Новый Структура("ТипЗначенийДоступа"));
	Поля.Добавить(Новый Структура("ВсеРазрешены"));
	Поля.Добавить(Новый Структура("ВсеРазрешеныБезИсключений"));
	Поля.Добавить(Новый Структура("БезНастройки"));
	
	Запрос.Текст = УправлениеДоступомСлужебный.ТекстЗапросаВыбораИзменений(
		ТекстЗапроса, Поля, "РегистрСведений.ЗначенияГруппДоступаПоУмолчанию", ТекстЗапросовВременныхТаблиц);
	
	УправлениеДоступомСлужебный.УстановитьУсловиеОтбораВЗапросе(Запрос, ГруппыДоступа, "ГруппыДоступа",
		"&УсловиеОтбораГруппДоступа1:ГруппыДоступа.Ссылка
		|&УсловиеОтбораГруппДоступа2:СтарыеДанные.ГруппаДоступа");
	
	Данные = Новый Структура;
	Данные.Вставить("МенеджерРегистра",      РегистрыСведений.ЗначенияГруппДоступаПоУмолчанию);
	Данные.Вставить("ИзмененияСоставаСтрок", Запрос.Выполнить().Выгрузить());
	Данные.Вставить("ИзмеренияОтбора",       "ГруппаДоступа");
	
	НачатьТранзакцию();
	Попытка
		ЕстьТекущиеИзменения = Ложь;
		УправлениеДоступомСлужебный.ОбновитьРегистрСведений(Данные, ЕстьТекущиеИзменения);
		Если ЕстьТекущиеИзменения Тогда
			ЕстьИзменения = Истина;
		КонецЕсли;
		
		Если ЕстьТекущиеИзменения
		   И УправлениеДоступомСлужебный.ОграничиватьДоступНаУровнеЗаписейУниверсально() Тогда
			
			// Планирование обновления доступа.
			СоставИзменений = Данные.ИзмененияСоставаСтрок.Скопировать(, "ГруппаДоступа, ТипЗначенийДоступа");
			СоставИзменений.Свернуть("ГруппаДоступа, ТипЗначенийДоступа");
			
			УправлениеДоступомСлужебный.ЗапланироватьОбновлениеДоступаПриИзмененииРазрешенныхЗначений(СоставИзменений);
		КонецЕсли;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Функция ВыбранныеЗначенияДоступа(ГруппыДоступа)
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ГруппыДоступа.Ссылка КАК Ссылка,
	|	ГруппыДоступа.Профиль КАК Профиль
	|ПОМЕСТИТЬ ГруппыДоступа
	|ИЗ
	|	Справочник.ГруппыДоступа КАК ГруппыДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ПрофилиГруппДоступа КАК ПрофилиГруппДоступа
	|		ПО ГруппыДоступа.Профиль = ПрофилиГруппДоступа.Ссылка
	|			И (ГруппыДоступа.Профиль <> ЗНАЧЕНИЕ(Справочник.ПрофилиГруппДоступа.Администратор))
	|			И (НЕ ГруппыДоступа.ПометкаУдаления)
	|			И (НЕ ПрофилиГруппДоступа.ПометкаУдаления)
	|			И (&УсловиеОтбораГруппДоступа1)
	|			И (ИСТИНА В
	|				(ВЫБРАТЬ ПЕРВЫЕ 1
	|					ИСТИНА КАК ЗначениеИстина
	|				ИЗ
	|					Справочник.ГруппыДоступа.Пользователи КАК УчастникиГруппДоступа
	|				ГДЕ
	|					УчастникиГруппДоступа.Ссылка = ГруппыДоступа.Ссылка))
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Ссылка,
	|	ГруппыДоступа.Профиль
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТИПЗНАЧЕНИЯ(ГруппыДоступаЗначенияДоступа.ЗначениеДоступа) КАК ТипЗначения,
	|	ГруппыДоступаЗначенияДоступа.ЗначениеДоступа КАК ЗначениеДоступа
	|ИЗ
	|	Справочник.ГруппыДоступа.ЗначенияДоступа КАК ГруппыДоступаЗначенияДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ГруппыДоступа КАК ГруппыДоступа
	|		ПО ГруппыДоступаЗначенияДоступа.Ссылка = ГруппыДоступа.Ссылка
	|ГДЕ
	|	ГруппыДоступаЗначенияДоступа.ВключаяНижестоящие
	|
	|СГРУППИРОВАТЬ ПО
	|	ТИПЗНАЧЕНИЯ(ГруппыДоступаЗначенияДоступа.ЗначениеДоступа),
	|	ГруппыДоступаЗначенияДоступа.ЗначениеДоступа
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ТИПЗНАЧЕНИЯ(ПрофилиГруппДоступаЗначенияДоступа.ЗначениеДоступа),
	|	ПрофилиГруппДоступаЗначенияДоступа.ЗначениеДоступа
	|ИЗ
	|	Справочник.ПрофилиГруппДоступа.ЗначенияДоступа КАК ПрофилиГруппДоступаЗначенияДоступа
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ГруппыДоступа КАК ГруппыДоступа
	|		ПО ПрофилиГруппДоступаЗначенияДоступа.Ссылка = ГруппыДоступа.Профиль
	|ГДЕ
	|	ПрофилиГруппДоступаЗначенияДоступа.ВключаяНижестоящие
	|
	|СГРУППИРОВАТЬ ПО
	|	ТИПЗНАЧЕНИЯ(ПрофилиГруппДоступаЗначенияДоступа.ЗначениеДоступа),
	|	ПрофилиГруппДоступаЗначенияДоступа.ЗначениеДоступа";
	
	Запрос = Новый Запрос(ТекстЗапроса);
	
	УправлениеДоступомСлужебный.УстановитьУсловиеОтбораВЗапросе(Запрос, ГруппыДоступа, "ГруппыДоступа",
		"&УсловиеОтбораГруппДоступа1:ГруппыДоступа.Ссылка");
	
	НастройкиЗначенийДоступа = Запрос.Выполнить().Выгрузить();
	
	Запрос = Новый Запрос;
	
	ТекстыЗапросов = Новый Массив;
	Для Индекс = 0 По НастройкиЗначенийДоступа.Количество() - 1 Цикл
		Настройка = НастройкиЗначенийДоступа[Индекс];
		
		ОбъектМетаданных = Метаданные.НайтиПоТипу(Настройка.ТипЗначения);
		Если ОбъектМетаданных = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ТекстЗапроса = 
		"ВЫБРАТЬ
		|	&ЗначениеДоступа КАК Значение,
		|	Таблица.Ссылка КАК ЗначениеВИерархии
		|ИЗ
		|	&Таблица КАК Таблица
		|ГДЕ
		|	Таблица.Ссылка В ИЕРАРХИИ(&ЗначениеДоступа)";
		
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&Таблица", ОбъектМетаданных.ПолноеИмя());
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ЗначениеДоступа", "&ЗначениеДоступа" + XMLСтрока(Индекс));
		Запрос.УстановитьПараметр("ЗначениеДоступа" + XMLСтрока(Индекс), Настройка.ЗначениеДоступа);
		ТекстыЗапросов.Добавить(ТекстЗапроса);
	КонецЦикла;
	
	ТекстЗапроса = СтрСоединить(ТекстыЗапросов, Символы.ПС + "ОБЪЕДИНИТЬ ВСЕ" + Символы.ПС);
	Запрос.Текст = ТекстЗапроса;
	
	Если ЗначениеЗаполнено(ТекстЗапроса) Тогда
		Результат = Запрос.Выполнить().Выгрузить();
	Иначе
		Результат = Новый ТаблицаЗначений;
		Результат.Колонки.Добавить("Значение", Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип);
		Результат.Колонки.Добавить("ЗначениеВИерархии", Метаданные.ОпределяемыеТипы.ЗначениеДоступа.Тип);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции


#КонецОбласти

#КонецЕсли
